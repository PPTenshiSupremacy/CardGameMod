switch(current_phase) {
	case phases.start:
		for(i=0; i<13; i++){
			var tempCard = instance_create_layer(64, 256, "Instances", oCard);
				with(tempCard){
					suit = 0;
					val = other.i+1;
				}
				show_debug_message(tempCard.suit*tempCard.val);
				array_push(cards, tempCard);
		}
		for(i=0; i<13; i++){
			//show_debug_message(i);
			var tempCard = instance_create_layer(64, 256, "Instances", oCard);
				with(tempCard){
					suit = 1;
					val = other.i+1;
				}
				show_debug_message(tempCard.suit*tempCard.val);
				array_push(cards, tempCard);
		}
		for(i=0; i<13; i++){
			var tempCard = instance_create_layer(64, 256, "Instances", oCard);
				with(tempCard){
					suit = 2;
					val = other.i+1;
				}
				show_debug_message(tempCard.suit*tempCard.val);
				array_push(cards, tempCard);
		}
		for(i=0; i<13; i++){
			var tempCard = instance_create_layer(64, 256, "Instances", oCard);
				with(tempCard){
					suit = 3;
					val = other.i+1;
				}
				show_debug_message(tempCard.suit*tempCard.val);
				array_push(cards, tempCard);
		}
		//Shuffle cards
		randomise();
		array_shuffle_ext(cards);
		//Copy array into stack
		for(i = 0; i<52; i++) {
			ds_stack_push(deck, cards[i]);
			//show_debug_message(ds_stack_size(deck));
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
	show_debug_message("dealing")
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
					dealCount=0;
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
			//show_debug_message("Resolve");

			if(showTimer == 0){
				//Check who has higher single card
				for(i=0; i<3; i++){
					aiHand[i].faceDown = false;
					if(aiHand[i].val>aiCardVal){
						aiCardVal = aiHand[i].val;
					}
					if(pHand[i].val>pCardVal){
						pCardVal = pHand[i].val;
					}
				}
				show_debug_message("AI Max Card");
				show_debug_message(aiCardVal);
				show_debug_message("Player Max Card");
				show_debug_message(pCardVal);
				for(i=0; i<3; i++){
					show_debug_message("AI Card");
					show_debug_message(aiHand[i].val);
				}
				for(i=0; i<3; i++){
					show_debug_message("Player Card");
					show_debug_message(pHand[i].val);
				}
				//Push centercard into both hands, then check
				array_push(aiHand, centerCard);
				array_push(pHand, centerCard);
				for(i=0; i<4; i++){
					comparator = aiHand[i].val;
					for(j=0; j<4; j++){
						if(comparator == aiHand[j].val){
							aiScore++;
						}
						if(aiScore>aiMax){
							aiMax = aiScore;
						}	
					}
					aiScore = 0;
				}
				for(i=0; i<4; i++){
					comparator = pHand[i].val;
					for(j=0; j<4; j++){
						if(comparator == pHand[j].val){
							pScore++;
						}
						if(pScore>pMax){
							pMax = pScore;
						}	
					}
					pScore = 0;
				}
				show_debug_message("AI Score");
				show_debug_message(aiMax);
				show_debug_message("Player Score");
				show_debug_message(pMax);
				if(aiMax == pMax){//Equal amount of combo
					if(aiCardVal == pCardVal){
						show_debug_message("True Draw");
					}
					else if(aiCardVal > pCardVal){
						aiRounds++;
						audio_play_sound(losePoint, 15, false);
						show_debug_message("Lose by high card");
					}
					else{
						pRounds++;
						audio_play_sound(getPoint, 15, false);
						show_debug_message("Win by high card");
					}
				}
				else if(aiMax>pMax){
					aiRounds++;
					audio_play_sound(losePoint, 15, false);
					show_debug_message("Lose by combo");
				}
				else{
					pRounds++;
					audio_play_sound(getPoint, 15, false);
					show_debug_message("Win by combo");
				}
				showTimer++;
			}
			else if(showTimer>0 && showTimer<240){
				showTimer++;
			}
			else{
				showTimer = 0;
				current_phase = phases.cleanup;
				yPos = discardY;
				show_debug_message(ds_stack_size(discard));
			}
			break;
		case phases.cleanup:
			//show_debug_message("Cleanup");
			
			switch(cleanStep){
				case 0://Move Centercard to discard
					if(lerpTimer == 0){
						ds_stack_push(discard, centerCard);
						centerCard.faceDown = true;
						lerpTimer++;
					}
					
					else if(lerpTimer>0 && lerpTimer<20){
						lerpTo(centerCard, discardX, yPos)
						lerpTimer++;
					}
					else{
						lerpTimer = 0;
						cleanStep++;
						audio_play_sound(moveCard, 10, false);
					}
					break;
				case 1://Start removing player and ai cards from hand
					
					//show_debug_message(moverCard.x);
					//show_debug_message(moverCard.y);
					if(lerpTimer == 0){
						moverCard = aiHand[0];
						moverCard.faceDown = true;
						ds_stack_push(discard, moverCard);
						lerpTimer++;
					}
					
					else if(lerpTimer>0 && lerpTimer<20){
						lerpTo(moverCard, discardX, yPos)
						lerpTimer++;
					}
					else{
						lerpTimer = 0;
						aiHand[0] = -1;
						cleanStep++;
						audio_play_sound(moveCard, 10, false);
					}
					break;
				case 2:
					if(lerpTimer == 0){
					moverCard = aiHand[1];
					moverCard.faceDown = true;
					ds_stack_push(discard, moverCard);
					lerpTimer++;
					
					}
					
					else if(lerpTimer>0 && lerpTimer<20){
						lerpTo(moverCard, discardX,yPos)
						lerpTimer++;
					}
					else{
						aiHand[1] = -1;
						lerpTimer = 0;
						cleanStep++;
						audio_play_sound(moveCard, 10, false);
					}
					break;
				case 3:
				if(lerpTimer == 0){
					moverCard = aiHand[2];
					moverCard.faceDown = true;
					ds_stack_push(discard, moverCard);
					lerpTimer++;
					
					}
					
					else if(lerpTimer>0 && lerpTimer<20){
						lerpTo(moverCard, discardX, yPos)
						lerpTimer++;
					}
					else{
						aiHand[2] = -1;
						lerpTimer = 0;
						cleanStep++;
						audio_play_sound(moveCard, 10, false);
					}
					break;
				case 4:
				if(lerpTimer == 0){
					moverCard = pHand[0];
					moverCard.faceDown = true;
					ds_stack_push(discard, moverCard);
					lerpTimer++;
					
					}
					
					else if(lerpTimer>0 && lerpTimer<20){
						lerpTo(moverCard, discardX,yPos)
						lerpTimer++;
					}
					else{
						pHand[0] = -1;
						lerpTimer = 0;
						cleanStep++;
						audio_play_sound(moveCard, 10, false);
					}
					break;
				case 5:
				if(lerpTimer == 0){
					moverCard = pHand[1];
					moverCard.faceDown = true;
					ds_stack_push(discard, moverCard);
					lerpTimer++;
					
					}
					
					else if(lerpTimer>0 && lerpTimer<20){
						lerpTo(moverCard, discardX, yPos)
						lerpTimer++;
					}
					else{
						pHand[1] = -1;
						lerpTimer = 0;
						cleanStep++;
						audio_play_sound(moveCard, 10, false);
					}
					break;
				case 6:
				if(lerpTimer == 0){
					moverCard = pHand[2];
					moverCard.faceDown = true;
					ds_stack_push(discard, moverCard);
					lerpTimer++;
					
					}
					
					else if(lerpTimer>0 && lerpTimer<20){
						lerpTo(moverCard, discardX,yPos)
						lerpTimer++;
					}
					else{
						pHand[2] = -1;
						lerpTimer = 0;
						cleanStep++;
						yPos = 0;
						audio_play_sound(moveCard, 10, false);
						
					}
					break;
				case 7://All cards in discard, shuffle discard into eck
					//Reshuffle discard pile into deck
					//show_debug_message("Reshuffling");
					//reshuffling = true;
					//show_debug_message("Stuck");
					if(activeCard == false && ds_stack_size(discard)!=0){//If card is not active, start new one
						activeCard = true;
						moverCard = ds_stack_pop(discard);
						show_debug_message("Running");
						//show_debug_message(ds_stack_size(discard));
					}
					else if(activeCard == true){
						if(lerpTimer < 10){
							moverCard.faceDown = true;
							var currentX = moverCard.x;
							var currentY = moverCard.y;
							var xx = lerp(currentX, deckX, 0.4);
							var yy = lerp(currentY, reshuffleYPos, 0.4);
							//Move card
							moverCard.x = xx;
							moverCard.y = yy;
							lerpTimer++;
							
							//show_debug_message(lerpTimer)
							//show_debug_message(int64(cardHolder.x));
						}
						else if(lerpTimer=10){
							show_debug_message("Finish");
							reshuffleCount++;
							audio_play_sound(moveCard, 10, false);
							moverCard.depth = -reshuffleCount;
							if(reshuffleCount%3 == 0){
								reshuffleYPos -=2;
							}
							activeCard = false;
							lerpTimer = 0;
							
						}
					}
					else if(activeCard == false && ds_stack_size(discard) == 0){
						array_shuffle_ext(cards);
						ds_stack_clear(deck);
						for(i = 0; i<52; i++) {
							ds_stack_push(deck, cards[i]);//Copy array into stack
							show_debug_message("Adding cards to deck");
						}
						show_debug_message(ds_stack_size(deck));
						//Reset positions to pile properly
						yPos = 256;
						for(i = 0; i<ds_stack_size(deck); i++) {
							cards[i].y=yPos;
							cards[i].depth = -i;
							if(i % 6 == 0){
								yPos-=4;
							}
						}
						
						reshuffleCount = 0;
						reshuffleYPos = 256;
						current_phase = phases.deal;
					}
					//show_debug_message("test");
					break;
			}
			break;
			
	default:
}
