import os
import sys
import logging

# 1. Setup Logger 
def setup_automation_logging():
    # 1. Define the format: Time - Level - Message
    log_format = '%(asctime)s - %(levelname)s: %(message)s'
    
    # 2. Configure the root logger
    logging.basicConfig(
        level=logging.INFO,        # Set the minimum level to capture
        format=log_format,
        handlers=[
            logging.StreamHandler(sys.stdout) # Send to terminal
        ]
    )
    return logging.getLogger(__name__)

# Usage
logger = setup_automation_logging()

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