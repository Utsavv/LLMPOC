from langchain_community.llms import Replicate
from LLama3 import Process_text

llm = Replicate(
    model="meta/meta-llama-3.1-405b-instruct",
    model_kwargs={"temperature": 0.0, "top_p": 1, "max_new_tokens": 500},
)


def Example_ChainOfThoughts():
    question = "who wrote the book Innovator's dilemma?"
    answer = llm.invoke(question)
    print(answer)
