
import time
import RPi.GPIO as GPIO


def ring_buzzer():
  GPIO.setwarnings(False)
  GPIO.setmode(GPIO.BCM)
  GPIO.setup(17,GPIO.OUT)

  loop_count = 30

  try:
    while loop_count > 0:
        GPIO.output(17,0)
        time.sleep(0.1)
        GPIO.output(17,1)
        time.sleep(0.1)
        loop_count = loop_count - 1
  except KeyboardInterrupt:
    GPIO.cleanup()
    exit

#ring_buzzer()
