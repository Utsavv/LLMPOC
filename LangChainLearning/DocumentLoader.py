import os
import openai
import sys

sys.path.append("../..")

# from dotenv import load_dotenv, find_dotenv

# _ = load_dotenv(find_dotenv())  # read local .env file

# openai.api_key = os.environ["OPENAI_API_KEY"]

from langchain.document_loaders import PyPDFLoader

loader = PyPDFLoader(
    "C:\W\OneDrive - Aristocrat Gaming\Loyalty\ATI Documentation\HALoCORE 3700 R2 Release Notes.pdf"
)
pages = loader.load()

print(len(pages))
page = pages[22]
print(page.metadata)
print(page.page_content)
