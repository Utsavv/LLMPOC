from langchain_community.chat_models import ChatOllama

llm = ChatOllama(model="llama3.1", temperature=0)
response = llm.invoke("who wrote the book godfather?")
print(response.content)
