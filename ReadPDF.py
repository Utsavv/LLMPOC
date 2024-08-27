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


pdf_path = "C:\W\OneDrive - Aristocrat Gaming\Loyalty\ATI Documentation\HALoCORE 3700 R2 Release Notes.pdf"
pdf_text = extract_text_from_pdf(pdf_path)
print(pdf_text)
