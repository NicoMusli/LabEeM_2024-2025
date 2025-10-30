/*
  CARD-SORTER-9000_library    by GRUPPO_01

  Libreria creata ad-hoc per definire le principali funzioni utilizzate nel codice eseguito dal sistema
  di card sorting progettato.
*/

#include<Wire.h>
#include<VL53L0X.h>
#include<Adafruit_TCS34725.h>
#include<Bounce2.h>
#include<ESP32Servo.h>
#include<BluetoothSerial.h>

/*
	La procedura prende in input gli oggetti che identificano i sensori e gli oggetti che definiscono le loro connessioni seriali.
	Essa inizializza i sensori con i parametri di connessione corretti, verificando che le connessioni siano effettuate correttamente.
*/
void deviceInit(VL53L0X &vl53, Adafruit_TCS34725 &tcs, TwoWire &vl53_I2C, TwoWire &tcs_I2C) {
	Serial.println("Inizializzo i sensori...\n");

	if(!tcs.begin(0x29, &tcs_I2C)) {
		Serial.println("Errore nell'inizializzare il TCS34725.\n");
		while(1);
  	}
  	Serial.println("Sensore TCS34725 inizializzato correttamente.");
  
  	vl53.setBus(&vl53_I2C);
  	if(!vl53.init()) {
		Serial.println("Errore inizializzazione VL53\n");
    	while(1);
  	}
  	vl53.startContinuous();
  	Serial.println("Sensore VL53L0X inizializzato correttamente.\n");

  	Serial.println("Sensori correttamente inizializzati.\n");
}

/*
	Semplice procedura che manda byte di dati a tutti gli indirizzi disponibili sul canale I2C datogli in input.
	Nello specifico verifica che sui due canali i sensori siano collegati correttamente.
*/
void scanI2C(TwoWire &Wire) {
	Serial.println("Scansionando il bus I2C...");
	byte error, address;
	int nDevices = 0;
  
	for(address = 1; address < 127; address++ ) {
    	Wire.beginTransmission(address);
    	error = Wire.endTransmission();
    
    	if (error == 0) {
    		Serial.print("Dispositivo trovato con indirizzo: 0x");
    		if (address<16) Serial.print("0");
    		Serial.println(address, HEX);
    		Serial.println(" ");
    		nDevices++;
    	}
  	}
  
	if (nDevices == 0) Serial.println("Nessun dispositivo trovato\n");
}

/*
	Funzione elementare che legge la distanza tramite l'apposito sensore 5 volte di fila e ne calcola e restituisce la media.
*/
float getDist(VL53L0X &vl53) {
	int i;
	float dist, sum, med;

	for(i=0; i<5; i++) {
		dist = float(vl53.readRangeContinuousMillimeters());
		sum += dist;
	}
	med = sum/5.0;

	return(med);
}

/*
	Procedura che normalizza i valor di Rosso, Verde e Blu letti dal sensore, rendendoli indipendenti dalla quantità di luce presente.
*/
void getRGB(uint16_t r, uint16_t g, uint16_t b, uint16_t c, float* nR, float* nG, float* nB) {
	*nR = (float)r/c;
	*nG = (float)g/c;
	*nB = (float)b/c;
}

/*
	Funzione che esegue il check della lettura dei colori, riconoscendo il colore corretto, restituendolo come array di caratteri.
*/
String getColor(float r, float g, float b, uint16_t c) {        
  if (r > 0.38 && g > 0.35 && b > 0.22 && c > 1800) return "Bianco";
  if (c < 900 && r < 0.52 && g < 0.4 && b < 0.25) return "Nero";
  if (r > 0.58 && g < 0.32 && b < 0.22) return "Rosso";
  if (r > 0.35 && g > 0.36 && b > 0.27) return "Blu";
  if (g > b && r > b && g > 0.35) return "Verde";
  return "Altro";
}

/*
	Procedura che, preso in input il colore restituito dalla funzione "getColor", muove gli attuatori riordinando le carte.
*/
void checkColor(string colore, Servo &servo, Servo &brush) {
	if(colore == "Blu" || colore == "Altro") {
		servo.write(0);
  		delay(1000);
  		if(colore == "Blu" ) brush.write(0); 
  		else brush.write(180);
	}
	else if(colore == "Verde" || colore == "Rosso") {
  		servo.write(60);
  		delay(1000);
  		if(colore == "Verde" ) brush.write(0); 
		else brush.write(180);
	} 
	else if(colore == "Nero" || colore == "Bianco") {
  		servo.write(120);
  		delay(1000);
  		if(colore == "Nero" ) brush.write(0); 
  		else brush.write(180);
	}
}