enum phases {
	start,
	deal,
	dealing,
	play,
	moving,
	resolve,
	cleanup
}

current_phase = phases.start;

//Setup Variables
cards = array_create(52);
deck = ds_stack_create();
discard = ds_stack_create();
pHand = array_create(3);
aiHand = array_create(3);
//Progress Variables
dealCount = 0;
dealTimer = 0;
aiTurn = 0;
aiCardSelected = false;
cardDealt = false;
lerpTimer = 0;
playerDiscard = false;
//Position Variables
deckX = 64;
deckY = 256;
pCardX = 440;
pCardY = 448;
aiCardX = 440;
aiCardY = 64;
centerX = 320;
centerY = 256;
discardX = 480;
discardY = 256;
//Holder Variables
centerCard = 0;
moverCard = 0;
cPos = 0;
//Scoring System Variables
pRounds = 0;
aiRounds = 0;
pScore = 0;
aiScore = 0;