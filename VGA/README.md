# Understanding VGA: How It Works and Its Standards  

## 1. VGA Signals  

VGA (Video Graphics Array) is an analog video standard that transmits images using separate RGB signals and synchronization signals.  

### Main VGA Signals  
- **Red (R)** — Analog intensity of the red color  
- **Green (G)** — Analog intensity of the green color  
- **Blue (B)** — Analog intensity of the blue color  
- **Horizontal Sync (HSYNC)** — Marks the end of a horizontal line  
- **Vertical Sync (VSYNC)** — Marks the end of a frame  

These signals are transmitted through a 15-pin D-SUB connector.

---

## 2. How VGA Displays an Image  

VGA works using a scanning system that draws the screen line by line:  

1. **Horizontal Scan**: The electron beam moves from left to right to draw a line.  
2. **Vertical Scan**: After each line, the beam moves down to the next row.  
3. **Complete Frame**: When all rows are drawn, the frame is complete, and the process repeats.  

### Synchronization Signals:  
- **HSYNC**: "Start a new line!"  
- **VSYNC**: "Start a new frame!"  

---

## 3. VGA Timing (Example: 640x480 @ 60Hz)  

VGA timing consists of different time intervals that define when pixels are drawn and when synchronization happens.

### Horizontal Timing (HSYNC)  
| Stage          | Pixels  | Description                 |
|---------------|---------|-----------------------------|
| Active pixels | 640     | Visible image               |
| Front porch   | 16      | Small delay before sync     |
| HSYNC pulse   | 96      | Horizontal sync signal      |
| Back porch    | 48      | Small delay after sync      |
| **Total**     | 800     | Complete horizontal cycle   |

### Vertical Timing (VSYNC)  
| Stage         | Lines   | Description                 |
|--------------|---------|-----------------------------|
| Active lines | 480     | Visible image               |
| Front porch  | 10      | Small delay before sync     |
| VSYNC pulse  | 2       | Vertical sync signal        |
| Back porch   | 33      | Small delay after sync      |
| **Total**    | 525     | Complete frame cycle        |

### Key Details  
- **Refresh rate**: 60 Hz (the screen refreshes 60 times per second).  
- **Pixel clock frequency**: 25.175 MHz.  
