// SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;


contract auction {

    uint8 private flagEndBid; //flag to indicate the end of the auction - bandera para saber la finalizacion de la subasta

    uint256 public intialValue; // intial value - Valor inicial 
    uint256 public saltoBid; // minimum bid increment in percentage - saltos minimos de puja
    uint256 public bidDuracion; // auction duration - Duracion de subasta
    uint256 public extenbidTime; // auction extension time (if near deadline) - Extencion de la subasta
    uint256 public maxOfferta; //highest offer made - Oferta maxima realizada 

    address private  winBidder; //winning bidder address- ofertante ganador
    address private  owner;  //auction owner address - propietario de la subast


//Constructor to initialize the auction - constructor para inciar la subasta
constructor(){
    owner = msg.sender;
    intialValue = 1 gwei ; //value intial
    bidDuracion = block.timestamp + 7 days; // duration auction 7 days
    saltoBid = 5; //Must be at least 5% higher
    extenbidTime = 10; // 10 minutes extra - condicion si falta 10 minutos


}



struct offer{
    address bidder;
    uint256 amount;
    uint256 offerDate;
}
offer[] private offers; //array of participants who made bids - array de participantes que ofertaron 

address[] private uniqueAddr; // array to store unique addresses - array para guardar las direc unicas

mapping (address => uint256) private balance; 




modifier verifyBid(){
    require(flagEndBid ==0, "The auction is over");
    require(block.timestamp <= bidDuracion, "The auction has expired");
    _;
}

modifier verifyOwner(){
    require(msg.sender == owner, "Only Owner enabled");
    _;
}

modifier activarBid(){
    require(flagEndBid ==1 , "the auction is not enabled");
    _;
}



// Function to place a bid
// - Must be at least 5% higher than the current max offer
// - Auction extends if bid is placed within last 10 minutes


function setOffer() external verifyBid payable {
    uint256 _offerAmount = msg.value;
    uint256 _limitOffer = maxOfferta + (maxOfferta * saltoBid/100);
    
    if( _offerAmount > _limitOffer ){
        address _addrBidder = msg.sender;
        winBidder = _addrBidder;
        maxOfferta = _offerAmount;

        uint256 _len = offers.length;
        uint8 _flagExistOffer ; 
        for (uint256 i = 0 ; i < _len ; i++){  // 
            if (_addrBidder == offers[i].bidder){ // check if the bidder already placed an offer and update it - verifica que si ya oferto y cambia la oferta
                offers[i].amount = _offerAmount;
                offers[i].offerDate = block.timestamp;
                _flagExistOffer = 1;
                break;
            }
        }


    
        // if this bidder has not placed an offer before - si no existe oferta de este antes
        if (_flagExistOffer == 0) {
        offers.push(offer(_addrBidder, _offerAmount, block.timestamp));
        }
        if(balance[_addrBidder]==0){
        uniqueAddr.push(_addrBidder);
        }
        balance[_addrBidder] += _offerAmount; //  store the bid value in the participant's balance - se guarda el valor de la oferta en el balance del participante

        emit Newoffer(_addrBidder, _offerAmount, block.timestamp  );
        if (block.timestamp >= (bidDuracion - extenbidTime)){
        bidDuracion = block.timestamp + extenbidTime;
        }
    }    
    else {
      
        revert("offer is low");
    }

    }


//Function to end the auction (only owner)- Función para finalizar subasta-(funcion)
function endSubasta() external verifyOwner {
    flagEndBid = 1;
    //emitir el evento finalizo
    emit BidEnding(winBidder, maxOfferta);

}



//Function to get the winning bidder and amount- Mostrar ganador y su oferta -(funcion)
function getWin() external view returns (address, uint256){
    return(winBidder, maxOfferta );
    }





// Function to view all offers- Mostrar los que ofertaron-
 function getOffers() external  view returns (offer[] memory) {
    return offers;
 }

// Function to return funds to all non-winning bidders -Devolver depósitos -(funcion)
 function returnOffers() external verifyOwner activarBid {
   uint256 _returnAmount; 
   uint256 _maxOffer = maxOfferta;
   uint256 _len = uniqueAddr.length; // check length

   for (uint256 i=0; i< _len ; i++){
        if(balance[uniqueAddr[i]] < _maxOffer){
            _returnAmount = balance[uniqueAddr[i]] - (balance[uniqueAddr[i]] * 2 / 100);
            balance[uniqueAddr[i]]= 0;
            payable (uniqueAddr[i]).transfer(_returnAmount);
        }

   } 
   payable (owner).transfer(address(this).balance);
}

// Function to allow partial refund of non-highest offers
function returnParcial() external verifyBid {
    uint256 _len = offers.length;
    uint256 i;
    uint256 _returnAmount; 
    uint8 _flagExist; 
    address _sender = msg.sender;

    for (i=0; i< _len ; i++){
        if (offers[i].bidder == _sender ){
            _flagExist = 1;
            break;
        }

    }
    require(_flagExist ==1, "Not a valid bidder");
    _returnAmount = balance[_sender] - offers[i].amount;
    require(_returnAmount >0, "Nothing to withdraw"); // validate refund
    balance[_sender] = balance[ _sender] - _returnAmount;
    payable (_sender).transfer(_returnAmount);
}




// Event for new offer -Nueva Oferta-(Evento)
event Newoffer (address indexed bidder, uint256 amount, uint256 timestamp);
 
// Event when auction ends -Subasta Finalizada-(Evento) 
event BidEnding (address indexed  bidder , uint256 amount);


}