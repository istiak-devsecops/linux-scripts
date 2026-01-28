import os
import sys
import logging

# 1. Setup Logger 
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

# 2. Define a Machine 
def check_environment():
    # os.getenv returns 'None' if the variable doesn't exist
    stage = os.getenv("STAGE") 
    return stage

# 3. Define the Flow 
def main():
    logger.info("Script started...")
    
    current_stage = check_environment()
    
    if current_stage is None:
        logger.error("Environment variable 'STAGE' is missing!")
        sys.exit(1) # Fail-fast
    
    logger.info(f"We are running in: {current_stage}")

# 4. Turn on the Power
if __name__ == "__main__":
    main()