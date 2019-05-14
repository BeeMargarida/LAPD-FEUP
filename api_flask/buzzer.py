
import time
import RPi.GPIO as GPIO


def ring_buzzer():
  GPIO.setmode(GPIO.BCM)
  GPIO.setup(17,GPIO.OUT)

  loop_count = 30

  try:
    while loop_count > 0:
        loop_count = loop_count - 1
        GPIO.output(17,GPIO.HIGH)
        time.sleep(0.5)
        GPIO.output(17,GPIO.LOW)
        time.sleep(0.5)
  except KeyboardInterrupt:
    GPIO.cleanup()
    exit

