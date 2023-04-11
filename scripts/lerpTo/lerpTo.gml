function lerpTo(card, xFinal, yFinal){
	var currentX = card.x;
	var currentY = card.y;
	var xx = lerp(currentX, xFinal, 0.4);
	var yy = lerp(currentY, yFinal, 0.4);
	//Move card
	card.x = xx;
	card.y = yy;
}