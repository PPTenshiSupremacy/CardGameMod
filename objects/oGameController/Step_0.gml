switch(current_phase) {
	case phases.start:
		//show_debug_message("Start Phase");
		//Create cards
		for(i = 0; i < 52; i++) {
			if(i < 13){
				var tempCard = instance_create_layer(64, 256, "Instances", oCard);
				with(tempCard){
					suit = suits.clubs;
					val = other.i+1;
				}
				cards[i] = tempCard;
			}
			else if(i >= 13 && i < 26){
				var tempCard = instance_create_layer(64, 256, "Instances", oCard);
				with(tempCard){
					suit = suits.diamonds;
					val = other.i-12;
				}
				cards[i] = tempCard;
			}
			else if(i >= 26 && i < 39){
				var tempCard = instance_create_layer(64, 256, "Instances", oCard);
				with(tempCard){
					suit = suits.hearts;
					val = other.i-25;
				}
				cards[i] = tempCard;
			}
			else if(i >= 39 && i < 52){
				var tempCard = instance_create_layer(64, 256, "Instances", oCard);
				with(tempCard){
					suit = suits.spades;
					val = other.i-38;
				}
				cards[i] = tempCard;
			}
		}
		//Shuffle cards
		randomise();
		array_shuffle_ext(cards);
		//Copy array into stack
		for(i = 0; i<52; i++) {
			ds_stack_push(deck, cards[i]);
			show_debug_message(ds_stack_size(deck));
		}
		//Reset positions to pile
		yPos = deckY;
		for(i = 0; i<ds_stack_size(deck); i++) {
			cards[i].y=yPos;
			cards[i].depth = -i;
			if(i % 6 == 0){
				yPos-=4;
			}
			
		}
		
		current_phase = phases.deal;
		break;
	case phases.deal:
		//Add 3 to both hand
		for(i = 0; i<3; i++){
			pHand[i] = ds_stack_pop(deck);
			aiHand[i] = ds_stack_pop(deck);
		}
		centerCard = ds_stack_pop(deck);
		current_phase = phases.dealing;
		break;
	case phases.dealing:
		switch(dealCount){
			case 0:
				//show_debug_message(pHand[0].y);
				if(dealTimer<20){
					lerpTo(pHand[0], pCardX, pCardY);
					dealTimer++;
				}
				else{
					dealCount++;
					audio_play_sound(moveCard, 10, false);
					dealTimer = 0;
					pHand[0].faceDown = false;
				}
				break;
			case 1:
				if(dealTimer<20){
					lerpTo(pHand[1], pCardX-16, pCardY);
					dealTimer++;
				}
				else{
					dealCount++;
					audio_play_sound(moveCard, 10, false);
					dealTimer = 0;
					pHand[1].faceDown = false;
				}
				break;
			case 2:
				if(dealTimer<20){
					lerpTo(pHand[2], pCardX-32, pCardY);
					dealTimer++;
				}
				else{
					dealCount++;
					audio_play_sound(moveCard, 10, false);
					dealTimer = 0;
					pHand[2].faceDown = false;
				}
				break;
			case 3:
				if(dealTimer<20){
					lerpTo(aiHand[0], aiCardX, aiCardY);
					dealTimer++;
				}
				else{
					dealCount++;
					audio_play_sound(moveCard, 10, false);
					dealTimer = 0;
				}
				break;
			case 4:
				if(dealTimer<20){
					lerpTo(aiHand[1], aiCardX-16, aiCardY);
					dealTimer++;
				}
				else{
					dealCount++;
					audio_play_sound(moveCard, 10, false);
					dealTimer = 0;
				}
				break;
			case 5:
				if(dealTimer<20){
					lerpTo(aiHand[2], aiCardX-32, aiCardY);
					dealTimer++;
				}
				else{
					dealCount++;
					audio_play_sound(moveCard, 10, false);
					dealTimer = 0;
				}
				break;
			case 6:
				if(dealTimer<20){
					lerpTo(centerCard, centerX, centerY);
					dealTimer++;
				}
				else{
					dealCount++;
					audio_play_sound(moveCard, 10, false);
					dealTimer = 0;
					centerCard.faceDown = false;
					current_phase = phases.play;
				}
		}
		break
	case phases.play:
		switch(aiTurn){//AI dumps minimum card, draws new one
			case 0:
				if(aiCardSelected == false){
					var aiMin= 20;
					var pos = 0;
					moverCard = aiHand[0];
					for(i = 0; i<array_length(aiHand); i++){
						//show_debug_message(moverCard.val);
						if(aiHand[i].val < aiMin){
							aiMin = aiHand[i].val;
							moverCard = aiHand[i];
							pos = i;
						}
					}
					aiHand[pos] = -1;
					aiCardSelected = true;
				}
				else if(lerpTimer<15 && aiCardSelected == true){
					lerpTo(moverCard, discardX, discardY);
					lerpTimer++;
				}
				else{//Finish moving dump card to discard
					audio_play_sound(moveCard, 10, false);
					aiTurn = 1;
					lerpTimer = 0;
					ds_stack_push(discard, moverCard)
					show_debug_message(ds_stack_size(discard));
					//for(i = 0; i<3; i++){
						//show_debug_message(aiHand[i]);
					//}
				}
				break;
				//Give AI new card
			case 1:
				if(cardDealt == false){
					for(i = 0; i<array_length(aiHand); i++){
						if(aiHand[i] == -1){
							cPos = i;
						}
					}
					aiHand[cPos] = ds_stack_pop(deck);
					moverCard = aiHand[cPos];
					cardDealt = true;
					//show_debug_message(cPos);
				}
				//New card assigned, lerp
				if(cardDealt == true && lerpTimer<20){
					//show_debug_message(cPos);
					lerpTo(moverCard, aiCardX-(cPos*16), aiCardY)
					lerpTimer++;
				}
				else{
					aiTurn = 2;
					lerpTimer = 0;
					cPos = 0;
					cardDealt = false;
					audio_play_sound(moveCard, 10, false);
					for(i = 0; i<array_length(aiHand); i++){
						aiHand[i].depth = i;
					}
					//show_debug_message("test");
				}
				
				//Throw temp into discard
				break;
			case 2://Player selecting card
				//show_debug_message("Player Turn");
				if(mouse_x>=408 && mouse_x<=471 && mouse_y>=400 && mouse_y<=495 && mouse_check_button_pressed(mb_left)){
					show_debug_message("0 Selected");
					moverCard = pHand[0];
					aiTurn = 3;
				}
				else if(mouse_x>=408 && mouse_x<=471 && mouse_y>=400 && mouse_y<=495)//Player Card 0
				{
					pHand[0].y = pCardY-16;
				}
				else{
					pHand[0].y = pCardY;
				}
				if(mouse_x>=392 && mouse_x<=407 && mouse_y>=400 && mouse_y<=495 && mouse_check_button_pressed(mb_left)){
					show_debug_message(" 1Selected");
					moverCard = pHand[1];
					aiTurn = 3;
				}
				else if(mouse_x>=392 && mouse_x<=407 && mouse_y>=400 && mouse_y<=495)//Player Card 0
				{
					pHand[1].y = pCardY-16;
				}
				else{
					pHand[1].y = pCardY;
				}
				if(mouse_x>=377 && mouse_x<=391 && mouse_y>=400 && mouse_y<=495 && mouse_check_button_pressed(mb_left)){
					show_debug_message(" 2Selected");
					moverCard = pHand[2];
					aiTurn = 3;
				}
				else if(mouse_x>=377 && mouse_x<=391 && mouse_y>=400 && mouse_y<=495)//Player Card 0
				{
					pHand[2].y = pCardY-16;
				}
				else{
					pHand[2].y = pCardY;
				}
				break;
			case 3:// Player card selected, lerp to discard and then give new one
				//Step 1: Remove player card from hand, add to discard
				if(playerDiscard == false){
					for(i=0; i<array_length(pHand); i++;){
						if(moverCard == pHand[i]){
							cPos = i;
						}
					}
					pHand[cPos] = -1;
					ds_stack_push(discard, moverCard);
					playerDiscard = true;
				}
				else if(lerpTimer<15 && playerDiscard == true){
					lerpTo(moverCard, discardX, discardY - (ds_stack_size(discard)*2));
					lerpTimer++;
				}
				else{
					lerpTimer = 0;
					moverCard.faceDown = true;
					show_debug_message(ds_stack_size(discard));
					audio_play_sound(moveCard, 10, false);
					aiTurn = 4;
				}
				break;
			case 4://Draw new player card
				if(cardDealt == false){
					pHand[cPos] = ds_stack_pop(deck);
					moverCard = pHand[cPos];
					cardDealt = true;
				}//Move Card
				else if(lerpTimer<20 && cardDealt ==true){
					lerpTo(moverCard, pCardX-(cPos*16), pCardY)
					lerpTimer++;
				}
				else{
					aiTurn = 0;
					lerpTimer = 0;
					pHand[cPos].faceDown = false;
					cPos = 0;
					current_phase = phases.resolve;
					cardDealt = false;
					audio_play_sound(moveCard, 10, false);
					for(i = 0; i<array_length(pHand); i++){
						pHand[i].depth = i;
					}
					//show_debug_message("test");
				}
				break;
		}
		break
		case phases.resolve:
			show_debug_message("Resolve");
			//Push centercard into both hands, then compare
			break;
	default:
}
