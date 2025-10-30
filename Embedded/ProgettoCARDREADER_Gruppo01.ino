/*
  CARD-SORTER-9000    by GRUPPO_01

  Il codice qui presente si occupa della pare embedded del progetto. Nello script proposto, si effettua la
  lettura del colore di una carta di MTG e la si ripone in modo automatico nel corretto conenitore.
  Per snellire il codice si è realizzata una apposita libreria contenente le funzioni e le procedure prin-
  -cipali, volte a svolgere i compiti centrali del sistema.
*/

#include<ProgettoGRUPPO1.h>

#define SCL0_pin 13  
#define SDA0_pin 14  
#define SCL1_pin 27  
#define SDA1_pin 26
#define SERVO_pin 18
#define BRUSH_pin 19
#define BUTTON_pin 23
#define RED_pin 16
#define GREEN_pin 17
#define BUZZER_pin 5

#define MIN_dist 60

// Inizializzazione delle connessioni I2C per i sensori
TwoWire vl53_I2C = TwoWire(0);
TwoWire tcs_I2C = TwoWire(1);

// Creazione degli oggetti (sensori, pulsante, servomotori e bluetooth)
VL53L0X vl53;
Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_154MS, TCS34725_GAIN_16X);
Bounce debouncer = Bounce();
Servo servo; Servo brush;
BluetoothSerial SerialBT;

// Variabili globali
float distSens; // Distanza letta dal sensore VL53L0X
uint16_t r, g, b, c; float nR, nG, nB; string colore;  // Variabili per la lettura e la manipolazione del colore
char received = 'N';  // Flag di ricezione OK dall'app

void setup() {
  Serial.begin(115200);
  delay(150);

  // Inizializzazione connessioni I2C
  vl53_I2C.begin(SDA0_pin, SCL0_pin);
  tcs_I2C.begin(SDA1_pin, SCL1_pin);

  // Inizializzazione sensori
  deviceInit(vl53, tcs, vl53_I2C, tcs_I2C);

  Serial.println("Verifico la connessione del sensore VL53L0X..."); scanI2C(vl53_I2C);
  Serial.println("Verifico la connessione del sensore TCS34725..."); scanI2C(tcs_I2C);

  pinMode(BUTTON_pin, INPUT_PULLUP);
  debouncer.attach(BUTTON_pin);
  debouncer.interval(25);
  
  pinMode(RED_pin, OUTPUT); digitalWrite(RED_pin, LOW);
  pinMode(GREEN_pin, OUTPUT); digitalWrite(GREEN_pin, LOW);
  pinMode(BUZZER_pin, OUTPUT); digitalWrite(BUZZER_pin, LOW);

  servo.attach(SERVO_pin); servo.write(0);
  brush.attach(BRUSH_pin); brush.write(90);

  Serial.println("Inizializzo la connessione Bluetooth, controlla i dispositivi disponibili sul tuo cellulare!"); SerialBT.begin("Card_Sorter_9000");
  while(!SerialBT.hasClient()) delay(100);
  Serial.println("Cellulare connesso correttamente!");

  delay(1000);
}

void loop() {
  servo.write(0);
  brush.write(90);
  digitalWrite(RED_pin, LOW);
  digitalWrite(GREEN_pin, LOW);

  distSens = getDist(vl53);

  while(distSens > MIN_dist) {
    distSens = getDist(vl53);
    Serial.print("Carta non presente\n Distanza (mm): ");
    Serial.println(distSens, DEC);
    digitalWrite(RED_pin, HIGH);
  }
  digitalWrite(RED_pin, LOW);
  digitalWrite(BUZZER_pin, HIGH);
  delay(100);
  digitalWrite(BUZZER_pin, LOW);

  Serial.println("Carta presente -----------> Valuto il colore");
  tcs.getRawData(&r, &g, &b, &c);

  Serial.print(" | R: "); Serial.print(nR);
  Serial.print(" | G: "); Serial.print(nG);
  Serial.print(" | B: "); Serial.print(nB);
  Serial.print(" | Clear: "); Serial.print(c);
  Serial.println("\n--------------------");

  getRGB(r, g, b, c, &nR, &nG, &nB);
  colore = getColor(nR, nG, nB, c);

  Serial.print("Colore rilevato: ");
  Serial.println(colore);

  delay(1000);
  checkColor(colore, servo, brush);

  Serial.print("Motore 1 in angolo: ");
  Serial.println(servo.read()); 
  Serial.print("Spazzola in angolo: ");
  Serial.println(brush.read());
  Serial.println("In attesa di segnale Bluetooth o pulsante premuto...");
  digitalWrite(RED_pin, HIGH);
  while(true) {
    debouncer.update();
    if(SerialBT.available()) received = SerialBT.read();
    if(debouncer.fell() || received == 'Y') {  
      Serial.println("OK!!");
      digitalWrite(RED_pin, LOW);
      digitalWrite(GREEN_pin, HIGH);
      digitalWrite(BUZZER_pin, HIGH);
      delay(100);
      digitalWrite(BUZZER_pin, LOW);
      break;
    }
  }

  delay(1000);
}