#!/usr/bin/env python
import logging

logging.basicConfig(level=logging.DEBUG, format=' %(asctime)s - %(levelname)s - %(message)s')
# You could also specific a file with filename='myProgramLog.log' within basicConfig

logging.debug("some minor code and debugging details.")
logging.info("An even happened")
logging.warning("Something could go wrong.")
logging.error('An error has occurred.')
logging.critical("The program is unable to recover!")

print ("Now again, but only error and above is displayed!")
logging.disable(logging.WARNING)
logging.debug("some minor code and debugging details.")
logging.info("An even happened")
logging.warning("Something could go wrong.")
logging.error('An error has occurred.')
logging.critical("The program is unable to recover!")
