# Example: reuse your existing OpenAI setup
from openai import OpenAI

# Point to the local server
client = OpenAI(base_url="http://localhost:1234/v1", api_key="lm-studio")

completion = client.chat.completions.create(
    model="lmstudio-community/Meta-Llama-3.1-8B-Instruct-GGUF",
    messages=[
        # {"role": "system", "content": "Always answer in rhymes."},
        {
            "role": "user",
            "content": "in sql server, how can we see if we have enough memory. I remember there was a query which used to tell how frequently a memory page is getting refreshed",
        },
    ],
    temperature=0.7,
)

print(completion.choices[0].message)
