import ollama
import PyPDF2
import pyodbc
import csv
import io
import os
import re
from typing import List, Dict


def extract_text_from_pdf(pdf_path: str) -> str:
    try:
        with open(pdf_path, "rb") as file:
            pdf_reader = PyPDF2.PdfReader(file)
            return "".join(page.extract_text() for page in pdf_reader.pages).strip()
    except Exception as e:
        return f"An error occurred: {str(e)}"


def process_text(content: str, stream: bool = True) -> str:
    messages = [{"role": "user", "content": content}]
    response = ollama.chat(model="llama3", messages=messages, stream=stream)

    if stream:
        for chunk in response:
            print(chunk["message"]["content"], end="", flush=True)
        return ""
    else:
        return "".join(chunk["message"]["content"] for chunk in response)


def read_text_file(file_path: str) -> str:
    try:
        with open(file_path, "r") as file:
            return file.read()
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return ""


def read_sql_files_from_folder(folder_path: str) -> str:
    all_content = []
    for filename in os.listdir(folder_path):
        if filename.endswith(".sql"):
            file_path = os.path.join(folder_path, filename)
            with open(file_path, "r") as file:
                content = file.read()
                content = re.sub(r"--.*\n", "", content)  # Remove single-line comments
                content = re.sub(
                    r"/\*.*?\*/", "", content, flags=re.DOTALL
                )  # Remove multi-line comments
                all_content.append(content)
    return "\n------SP Definition Finished------\n".join(all_content)


def execute_query(
    query: str, server_name: str = ".", database_name: str = "AdventureWorks2019"
) -> str:
    conn_str = f"DRIVER={{SQL Server}};SERVER={server_name};DATABASE={database_name};Trusted_Connection=yes"
    with pyodbc.connect(conn_str) as conn:
        cursor = conn.cursor()
        cursor.execute(query)
        results = cursor.fetchall()

        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow([col[0] for col in cursor.description])
        writer.writerows(results)

        return output.getvalue()


def summarize_pdf(pdf_path: str):
    pdf_text = extract_text_from_pdf(pdf_path)
    process_text(f"Could you please summarize the following: {pdf_text}")


def compare_pdfs(pdf_path1: str, pdf_path2: str):
    pdf_text1 = extract_text_from_pdf(pdf_path1)
    pdf_text2 = extract_text_from_pdf(pdf_path2)
    question = (
        f"Given below are two release notes. Could you please compare both and provide a report on what has changed between both versions?\n"
        f"Release note 1: {pdf_text1}\n"
        f"Release note 2: {pdf_text2}"
    )
    process_text(question)


def business_question_scenario(table_files: Dict[str, str], question: str):
    table_structures = {
        name: read_text_file(path) for name, path in table_files.items()
    }

    sql_query = process_text(
        f"Assume you are a SQL developer. Write a SQL query to answer this business question:\n\n"
        f"{question}\n\n"
        f"Table structures:\n\n"
        f"{chr(10).join(f'Table {name}:\n{structure}' for name, structure in table_structures.items())}\n\n"
        f"Please provide only the SQL query without any explanation or markdown.",
        stream=False,
    )

    dataset = execute_query(sql_query)

    analysis_question = (
        f"Assume you are a business analyst. Write an email to your manager based on this CSV data:\n\n"
        f"{dataset}\n\n"
        f"Frame a sentence for every row instead of using a tabular format. Include the complete CSV in your response."
    )
    process_text(analysis_question)


def create_new_sp(folder_path: str):
    training_data = read_sql_files_from_folder(folder_path)
    question = (
        f"Assume you are a senior SQL server developer. You have the following existing stored procedures for reference:\n\n"
        f"{training_data}\n"
        f"Please list the names of all stored procedures you can find. There are 7 SPs in total. "
        f"Hint: every SP ends with the line ------STARTING NEW SP------"
    )
    process_text(question)


def create_test_cases_from_code(table_files: Dict[str, str], sp_file: str):
    table_scripts = {name: read_text_file(path) for name, path in table_files.items()}
    sp_script = read_text_file(sp_file)

    question = (
        f"Assume you are a manual test engineer. Your task is to write extensive test cases to cover the stored procedure dbo.uspGetManagerEmployees.\n"
        f"This stored procedure uses a recursive query to return the direct and indirect employees of the specified manager.\n"
        f"Input parameter: a valid BusinessEntityID of the manager from the HumanResources.Employee table\n\n"
        f"Table scripts:\n"
        f"{chr(10).join(f'{name}:\n{script}' for name, script in table_scripts.items())}\n\n"
        f"SQL SP definition:\n{sp_script}"
    )
    process_text(question)


if __name__ == "__main__":
    # Uncomment the function you want to run
    # summarize_pdf("path/to/your/pdf")
    # compare_pdfs("path/to/pdf1", "path/to/pdf2")
    # business_question_scenario(
    #     {
    #         "PERSON.ADDRESS": "C:\\W\\GIT\\LLMPOC\\LLMPOC\\AdventureWorks\\ADVENTUREWORKS.PERSON.ADDRESS.sql",
    #         "PERSON.Person": "C:\\W\\GIT\\LLMPOC\\LLMPOC\\AdventureWorks\\PERSON.Person.sql",
    #         "PERSON.BusinessEntityAddress": "C:\\W\\GIT\\LLMPOC\\LLMPOC\\AdventureWorks\\PERSON.BusinessEntityAddress.sql"
    #     },
    #     "Get me complete address of all persons living in San Francisco?"
    # )
    # create_new_sp("C:\\W\\GIT\\LLMPOC\\LLMPOC\\EB")
    create_test_cases_from_code(
        {
            "HumanResources.Employee": "C:\\W\\GIT\\LLMPOC\\LLMPOC\\AdventureWorks\\HumanResources.Employee.sql",
            "Person.Person": "C:\\W\\GIT\\LLMPOC\\LLMPOC\\AdventureWorks\\Person.Person.sql",
            "Person.BusinessEntity": "C:\\W\\GIT\\LLMPOC\\LLMPOC\\AdventureWorks\\Person.BusinessEntity.sql",
        },
        "C:\\W\\GIT\\LLMPOC\\LLMPOC\\AdventureWorks\\dbo.uspGetManagerEmployees.sql",
    )
