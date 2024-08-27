# following PIP should work
# pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
# Olama may need to be installed from ollama website first
# pip install ollama
# pip install sentencepiece
# pip install ipywidgets

import torch
import ollama
from transformers import LlamaForCausalLM, LlamaTokenizer
from datasets import load_dataset

# Load the tokenizer and model
model_name = "llama3"
tokenizer = LlamaTokenizer.from_pretrained(model_name)
model = LlamaForCausalLM.from_pretrained(model_name)

# Load your dataset
dataset = load_dataset("csv", data_files="./student_performance.csv")


# Tokenize the dataset
def tokenize_function(examples):
    return tokenizer(examples["text"], padding="max_length", truncation=True)


tokenized_datasets = dataset.map(tokenize_function, batched=True)

# Set training arguments
from transformers import Trainer, TrainingArguments

training_args = TrainingArguments(
    output_dir="./llama3-finetuned",
    evaluation_strategy="epoch",
    learning_rate=2e-5,
    per_device_train_batch_size=4,
    num_train_epochs=3,
    weight_decay=0.01,
)

# Create Trainer instance
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_datasets["train"],
    eval_dataset=tokenized_datasets["test"],
)

# Start training
trainer.train()

# Save the model
trainer.save_model("./llama3-finetuned")
