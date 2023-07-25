shader_type spatial;

void vertex() {
	VERTEX.x += sin(VERTEX.y) * cos(TIME);
	VERTEX.y += sin(VERTEX.z) * cos(TIME);
	VERTEX.z += sin(VERTEX.x) * cos(TIME);
	
	VERTEX.x *= sin(TIME) + 1.0;
}