import ollama
import PyPDF2


def extract_text_from_pdf(pdf_path):
    text = ""
    try:
        with open(pdf_path, "rb") as file:
            pdf_reader = PyPDF2.PdfReader(file)
            for page in pdf_reader.pages:
                text += page.extract_text()
    except Exception as e:
        return f"An error occurred: {str(e)}"

    return text.strip()


def Process_text(content):
    stream = ollama.chat(
        model="llama3",
        messages=[
            {
                "role": "user",
                "content": content,
            }
        ],
        stream=True,
    )

    for chunk in stream:
        print(chunk["message"]["content"], end="", flush=True)


# Example 1 - summarize PDF
# pdf_path = "C:\W\OneDrive - Aristocrat Gaming\Loyalty\ATI Documentation\HALoCORE 3700 R2 Release Notes.pdf"
# pdf_text = extract_text_from_pdf(pdf_path)
# Process_text("Could you please summarize following - " + pdf_text)

# Example 2 - Compare and extract information from two PDFs
pdf_path1 = (
    "C:\\Users\\vermau\\Downloads\\Oasis Loyalty v1.3, v1.3.1001 Release Notes.pdf"
)
pdf_path2 = (
    "C:\\Users\\vermau\\Downloads\\Oasis Loyalty v1.4 and v1.4.1001 Release Notes.pdf"
)

pdf_text1 = extract_text_from_pdf(pdf_path1)
pdf_text2 = extract_text_from_pdf(pdf_path2)

Question = (
    "Given below are two release notes. Could You please compare both and provide a report what has been changed between both versions?"
    + "Release note 1 - "
    + pdf_text1
    + "Release note 2 - "
    + pdf_text2
)

Process_text(Question)
