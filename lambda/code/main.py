import sys
import yaml
import logging

YAML_DOC = """
---
names:
- Bill
- John
- Bob
...
"""

def lambda_handler(event, context):
    logger = logging.getLogger(__name__)
    logger.info("Hello from Lambda")
    result = yaml.dump(yaml.load(YAML_DOC, Loader=yaml.SafeLoader), default_flow_style=False)
    return result

if __name__ == '__main__':
    logger = logging.getLogger(__name__)
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.INFO)
    handler.setFormatter(logging.Formatter('%(message)s'))
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    result = lambda_handler(None, None)
    logger.info(result)
