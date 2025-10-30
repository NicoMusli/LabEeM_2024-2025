# 🧠 CardSorter-9000
### Semi-Automated Magic: The Gathering Card Sorting System

**Academic Year:** 2024/2025  
**Keywords:** Embedded Systems, ESP32, Flutter, Bluetooth, Automation, Magic: The Gathering  

---

## 📖 Overview

**CardSorter-9000** is a semi-automated system designed to simplify the organization of *Magic: The Gathering* cards.  
As collections grow over the years, manually sorting cards becomes increasingly time-consuming.  
This project aims to **automate** and **digitize** that process by combining an **ESP32-based embedded system** and a **mobile app**.

The project emphasizes two principles:
- 🧩 **Affordability:** Built using low-cost, easily accessible components.  
- 🛠️ **Reproducibility:** Designed for DIY makers and open-source collaboration.

The system recognizes the color of each card, automatically sorts it into the correct container,  
and logs its data through a connected Android app that retrieves card details via the **Scryfall API**.

---

## 🎯 Objectives

- Automatically detect the color of Magic: The Gathering cards.  
- Mechanically sort cards into the correct bins based on their color.  
- Send card data to a mobile app via Bluetooth.  
- Enable semi-automatic cataloging and visualization of cards within the app.  

---

## 🧱 System Architecture

The CardSorter-9000 system is composed of two main subsystems:

### 🔹 Embedded System (ESP32)
- Detects card presence using a **VL53L0X Time-of-Flight distance sensor**.  
- Identifies card color using a **TCS34725 RGB color sensor**.  
- Controls **two MG90S servo motors** for card sorting.  
- Provides **LED and buzzer feedback** for user interaction.  
- Communicates with the mobile app via **Bluetooth Classic**.

### 🔹 Mobile Application (Flutter)
- Built with the **Flutter framework** for Android support and future multiplatform expansion.  
- Displays card details, including stats and images, retrieved from the **Scryfall API**.  
- Allows users to confirm card additions, filter, and search through their collection.  
- Stores data locally in a JSON file (`assets.json`).

---

## 🧩 Functional Requirements (FURPS+ Model)

### Functionality
- **F1:** Automatically recognize the card color (Blue, Black, White, Green, Red, or Other).  
- **F2:** Sort cards according to detected color.  
- **F3:** Send color notification to the mobile app.  
- **F4:** Allow users to add card names to their digital collection.

### Usability
- **U1:** Provide LED and buzzer feedback when a card is detected.  
- **U2:** Offer a simple, visual mobile UI displaying card stats and images.

### Reliability
- **R1:** Achieve at least 90% color recognition accuracy.  
- **R2:** Notify users of Bluetooth connection loss and guide reconnection.

### Performance
- **P1:** Color recognition and notification in under 2 seconds.  
- **P2:** Establish Bluetooth connection in under 2 seconds.

### Supportability
- **S1:** Modular codebase allowing easy updates (e.g., name recognition).  
- **S2:** Full Android compatibility.

### Other Requirements
- **A1:** Bluetooth communication.  
- **A2:** Card data fetched via the **Scryfall API**.  
- **A3:** Operates at 5V / 3.3V.  
- **A4:** Based on the **ESP32 development board**.

---

## 🧠 Use Cases

- **UC1:** Insert card into the reader.  
- **UC2:** Input card name in the app.  
- **UC3:** Trigger bypass button.  
- **UC4:** Modify collection.  
- **UC5:** Measure distance.  
- **UC6:** Recognize card color.  
- **UC7:** Sort card automatically.  
- **UC8:** Send color data to the app.  
- **UC9:** Establish Bluetooth connection.  
- **UC10:** Add card to digital collection.  
- **UC11:** Retrieve data via the Scryfall API.

---

## 🧰 Hardware Components

| Component | Description |
|------------|-------------|
| **ESP32 Dev Module** | Microcontroller handling sensors, motors, and Bluetooth communication. |
| **VL53L0X** | Time-of-Flight laser sensor for distance detection. |
| **TCS34725** | RGB color sensor with built-in IR filter. |
| **2x MG90S Servo Motors** | Mechanically sort cards into bins. |
| **LEDs (Red & Green)** | Provide visual feedback. |
| **Active Buzzer** | Provides auditory feedback. |
| **Breadboard & Power Supply** | Prototype assembly and testing. |

---

## 📱 Mobile App Structure

**Main Components:**
- `Homepage` / `HomePageState`: Core logic, Bluetooth management, and UI widgets.  
- `MagicCardApi`: Handles HTTP requests to the Scryfall API.  
- `CardListWidget` / `CardWidget`: Visual representation of cards.  
- `GameCard`: Class model for card objects.  
- `CardDialogs`: Manages dialogs for adding, editing, and deleting cards.

---

## 💾 Communication & Data Flow

1. ESP32 detects a card and reads its color.  
2. Color data is transmitted to the app via Bluetooth.  
3. The app alerts the user and requests card confirmation.  
4. The user inputs the card name.  
5. The app fetches additional details from the Scryfall API.  
6. The new card is added to the local collection and confirmed to the ESP32.  

---

## 🧪 Testing

- Simulated with colored paper cards to calibrate color readings.  
- A black paper cylinder was added to minimize ambient light interference.  
- Arduino UNO used as auxiliary power source for servos during testing.  
- Debug messages printed on Arduino Serial Monitor.  
- Color calibration performed within the `checkColor()` function to optimize detection accuracy.

---

## 📊 Results & Discussion

- Red and white cards required extra calibration due to sensor sensitivity.  
- System achieved stable and repeatable color recognition after calibration.  
- Bluetooth communication maintained reliability within a 2-second reconnect window.  
- Demonstrated seamless interaction between hardware and mobile systems.

---

## 🚀 Future Improvements

- Replace JSON storage with a **cloud-based database** for multi-user support.  
- Integrate **camera-based recognition** and **machine learning** for full card identification.  
- Design a **3D-printed sorting chassis** for stable physical deployment.  
- Improve sensor precision and hardware integration for commercial scalability.

---

## 🧾 License

This project is intended for educational and open-source use.  
Feel free to modify, extend, and share improvements under the terms of the MIT License.

---

## 👥 Contributors

- Nicola Musicco  
- Benedictis Riccardo
- Cialdella Andrea

---

## 🔗 References

- [Scryfall API](https://scryfall.com/)  
- [ESP32 Official GitHub](https://github.com/espressif)  
- [SoftWire Library](https://github.com/stevemarple/SoftWire)
