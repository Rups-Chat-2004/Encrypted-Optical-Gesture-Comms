#  Encrypted Optical Gesture-Based Communication System Using AES-256 Over Free-Space Optics

> A MATLAB-based project demonstrating secure communication using real-time hand gestures, AES-256 encryption, and Free-Space Optical (FSO) transmission — tailored for defense applications.

##  Overview

In RF-compromised military zones, conventional communication methods are prone to interception and jamming. This project presents a novel simulation of a **gesture-based encrypted communication system** using **Free-Space Optics (FSO)** and **AES-256 encryption**, entirely implemented in **MATLAB**.

Hand gestures are captured using a webcam, converted to encrypted military commands, modulated optically, and securely transmitted through a simulated FSO channel.

##  Objectives

-  Capture military gestures using a webcam.
-  Recognize gestures and map them to predefined commands.
-  Encrypt commands with AES-256 encryption.
-  Transmit data over a simulated FSO link using intensity modulation.
-  Demodulate and decrypt received data to retrieve original commands.

##  Technologies Used

- **MATLAB 2024**
  - Image Processing Toolbox
  - Signal Processing Toolbox
  - Java Cryptography Extension (JCE)
- AES-256 encryption
- Webcam interface (DroidCam)

## ⚙ System Workflow

1. **Gesture Capture:** Webcam acquires real-time hand gestures.
2. **Image Processing:** Grayscale conversion, binarization, and feature extraction.
3. **Gesture Recognition:** Classifies gestures like `STOP`, `V`, `FIST`, `THUMBS_UP`.
4. **Encryption:** Converts command to encrypted bitstream using AES-256.
5. **FSO Modulation:** Simulates intensity modulation where `1` → sine wave, `0` → silence.
6. **Reception & Demodulation:** Reconstructs bitstream and decrypts it to recover the command.

##  Results

- 100% accurate gesture classification under ideal lighting.
- Successful AES-256 encryption/decryption.
- Robust signal clarity in optical modulation simulation.
- Visual output includes time-domain plots and signal recovery stages.


