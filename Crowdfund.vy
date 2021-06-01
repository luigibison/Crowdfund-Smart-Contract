# Crowdfunding de apenas 1 projeto

struct Doador :
  donator: address
  value: uint256
 
funders: HashMap[int128, Doador]
nextfund: int128
owner: address
end_date: public(uint256)
goal: public(uint256)
refu: int128
time: public(uint256)
 

# Função que roda quando é feito o deploy do contrato
@external
def __init__(_owner: address, _goal: uint256, _time: uint256):
    self.owner = _owner
    self.end_date = block.timestamp + _time
    self.time = _time
    self.goal = _goal
 

# Participar da Campanha
@external
@payable
def participate():
    assert block.timestamp < self.end_date, "Prazo para participação expirado"
 
    nfi: int128 = self.nextfund
 
    self.funders[nfi] = Doador({donator: msg.sender, value: msg.value})
    self.nextfund = nfi + 1
 

# Meta de Crowdfunding Atingida! Retirar fundos!
@external
def finish():
    assert block.timestamp >= self.end_date, "Prazo ainda não Atingido"
    assert self.balance >= self.goal, "Valor da Meta não Atingida :("
 
    selfdestruct(self.owner)
 
# Meta de Crowdfunding não Atingida! Devolver o dinheiro para os doadores!
@external
def refund():
    assert block.timestamp >= self.end_date and self.balance < self.goal
 
    ind: int128 = self.refu
 
    for i in range(ind, ind + 300):
        if i >= self.nextfund:
            self.refu = self.nextfund
            return
 
        send(self.funders[i].donator, self.funders[i].value)
        self.funders[i] = empty(Doador)
 
    self.refu = ind + 300