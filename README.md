# Linux Remote CLI

![.NET](https://img.shields.io/badge/.NET-10.0-512BD4)
![License](https://img.shields.io/badge/license-Apache--2.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.38.5%20(stable)-02569B?logo=flutter)
![Linux](https://img.shields.io/badge/Target-Linux-black)
![Android](https://img.shields.io/badge/Android-APK-2d2d2d?logo=android)

A lightweight mobile app for remotely managing Linux systems, with a backend server for real-time command execution and system monitoring.
Backend powered by **ASP.NET Core + SignalR**, frontend built with **Flutter (Cupertino UI)**.

<p align="center">
  <img src="https://github.com/user-attachments/assets/cbeed458-98b9-4bae-8829-c82395cf90d8" width="220" />
  <img src="https://github.com/user-attachments/assets/93b1d883-a503-4892-bf0f-d08d7a9e8819" width="220" />
</p>

## Features

- Remote command execution via SSH
- `sudo` support (password stored only in memory)
- Persistent shell state (`cd`, working directory)
- Command cancellation (Stop execution)
- Real-time system monitoring with live updates:
  - OS info
  - CPU load
  - RAM usage
- Clean Cupertino-style mobile UI

## Security Notes

- SSH credentials are provided by the client only.
- Sudo password is **not persisted on the backend**.
- Client-side secrets stored securely.

## Getting Started 

### Backend
```bash
dotnet restore
dotnet run
```
> [!IMPORTANT]
> Make sure the backend runs on a Linux system if you want full system monitoring support.
### Frontend

1. Install the provided APK on your device.  
2. Open the app, go to **Settings**, and fill in:
   - **Host Address** (Linux server IP)  
   - **URL** (SignalR Hub endpoint, e.g., `http://<host>:5050/systemHub`)  
   - **Username / Password** (Linux credentials)  
   - **sudo password** (if needed)  
3. Tap **Connect** to start monitoring and executing commands.

---
<img src="https://i.pinimg.com/originals/51/89/7e/51897e47a633a645d034f9135e6d8992.gif" width="1000" height="300" alt="Demo">
