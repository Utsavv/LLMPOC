import ollama
import PyPDF2
import pyodbc
import csv, io, os, re


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


def Process_return_text(content):
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

    output_text = ""
    for chunk in stream:
        output_text += chunk["message"]["content"]

    return output_text


def Example1_SummarizePDF():
    # Example 1 - summarize PDF
    pdf_path = "C:\W\GIT\LLMPOC\LLMPOC\EB\Anthropic.pdf"
    pdf_text = extract_text_from_pdf(pdf_path)
    Process_text(
        "Could you please highlight key features discussed in given document? "
        + "Also please write how these fetaures can be helpful in casino industry."
        + pdf_text
    )


def Exmaple2_ComparePDF():
    # Example 2 - Compare and extract information from two PDFs
    pdf_path1 = "C:\W\GIT\LLMPOC\LLMPOC\EB\Anthropic.pdf"
    pdf_path2 = "C:\W\GIT\LLMPOC\LLMPOC\EB\OpenAIChatGPT.pdf"

    pdf_text1 = extract_text_from_pdf(pdf_path1)
    pdf_text2 = extract_text_from_pdf(pdf_path2)

    Question = (
        "Given below are two documents containing features od two GPTs."
        + "Could You please compare both and provide a report"
        + "explaining main difference between both documents?"
        + "Release note 1 - "
        + pdf_text1
        + "Release note 2 - "
        + pdf_text2
    )

    Process_text(Question)


# Example 3 - generate a query and execute
# Will need to restore database
# Load tables' structure from a file for easy readability
# Translate a business question and generate query
# Execute generated query against local database


def read_text_file(file_path):
    """
    Reads a text file and returns its contents.

    Args:
        file_path (str): Path to the text file

    Returns:
        str: Contents of the text file
    """
    try:
        with open(file_path, "r") as file:
            contents = file.read()
        return contents
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return None


def read_files_from_folder():
    source_folder = "C:\W\GIT\LLMPOC\LLMPOC\EB"  # Replace with your folder path
    all_content = ""

    for filename in os.listdir(source_folder):
        if filename.endswith(".sql"):  # Check if file is an SQL file
            file_path = os.path.join(source_folder, filename)
            with open(file_path, "r") as file:
                content = file.read()
                # Remove single-line comments
                content = re.sub(r"--.*\n", "", content)
                # Remove multi-line comments
                content = re.sub(r"/\*.*?\*/", "", content, flags=re.DOTALL)
                all_content += content + "\n------SP Definition Finished------\n"

    return all_content


def execute_query(query):
    server_name = "."
    database_name = "AdventureWorks2019"

    conn_str = f"DRIVER={{SQL Server}};SERVER={server_name};DATABASE={database_name};Trusted_Connection=yes"
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    cursor.execute(query)
    results = cursor.fetchall()

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow([col[0] for col in cursor.description])  # header row
    writer.writerows(results)

    conn.close()
    return output.getvalue()


def Example3_Business_question_Scenario():
    file_path = (
        "C:\W\GIT\LLMPOC\LLMPOC\AdventureWorks\ADVENTUREWORKS.PERSON.ADDRESS.sql"
    )
    person_address = read_text_file(file_path)
    file_path = "C:\W\GIT\LLMPOC\LLMPOC\AdventureWorks\PERSON.Person.sql"
    person_person = read_text_file(file_path)
    file_path = "C:\W\GIT\LLMPOC\LLMPOC\AdventureWorks\PERSON.BusinessEntityAddress.sql"
    person_BusinessEntityAddress = read_text_file(file_path)

    Business_Question = "Get me complete address, including full name, of all persons living in city San Francisco?"

    Question = (
        "Assume that you are a SQL developer and you need to write a sql query to provide answer to question asked by a business user\n\n"
        + "\n\nBusiness question is as following - \n\n"
        + Business_Question
        + "\n\nPlease write a sql query based on following table structure.\n\n"
        + "\n\nTable structure 1 - \n\n"
        + person_address
        + "\n\nTable structure 2 - \n\n"
        + person_BusinessEntityAddress
        + "\n\nTable structure 3 - \n\n"
        + person_person
        + "\n\n Please provide only SQL query and no explanation or pretext or markdown or unwanted special characters."
        + "\n\n I want to use output as it is to execute query without any modification."
    )

    Query = Process_return_text(Question)
    print(f"\n\nFollowing is the query generated by LLM \n\n{Query}\n\n")
    Dataset = execute_query(Query)
    print(f"\n\nDataset returned by query - \n\n{Dataset}\n\n")
    Question = (
        "Assume that you are a business analyst and you need to send an email to your manager."
        + "\n\nPlease write following CSV in such a way that it can be sent as an email to my manager\n\n"
        + "\n\Please frame a sentence for every row instead of tabular format. "
        + "Please include an interesting fact about every address \n\n"
        + Dataset
        # + "Each sentence should include distance from address mentioned in previous row."
        + "Please include only top 10 rows from CSV in your response."
    )
    Process_text(Question)


def write_to_file(content, filename):
    with open(filename, "w") as file:
        file.write(content)


def Example4_CreateNewSP():
    TrainingData = read_files_from_folder()
    Question = (
        "Assume that you are a senior SQL server developer. You have following existing stored procedures for reference - \n\n"
        + TrainingData
        + "Please list name of all stored procedures you can find. I know there are 7 SPs. Hint - every SP is ending with line ------STARTING NEW SP------"
        # + "\n\n Please write a query to extract a player's balance on each property."
        # + "\n\n Please provide only SQL query and no explanation or pretext or markdown. I want to use output as it is to execute query without any modification."
    )
    # write_to_file(TrainingData, "output.txt")
    Process_text(Question)


def Example5_CreateTestCasesFromCode():
    TableScript1 = read_text_file(
        "C:\W\GIT\LLMPOC\LLMPOC\AdventureWorks\HumanResources.Employee.sql"
    )
    TableScript2 = read_text_file(
        "C:\W\GIT\LLMPOC\LLMPOC\AdventureWorks\Person.Person.sql"
    )
    TableScript3 = read_text_file(
        "C:\W\GIT\LLMPOC\LLMPOC\AdventureWorks\Person.BusinessEntity.sql"
    )
    SPScript = read_text_file(
        "C:\W\GIT\LLMPOC\LLMPOC\AdventureWorks\dbo.uspGetManagerEmployees.sql"
    )

    Question = (
        "Assume that you are a manual test engineer. You task is to write extensive test case to cover stored procedure dbo.uspGetManagerEmployees."
        + "\nThis stored procedure using a recursive query to return the direct and indirect employees of the specified manager."
        + "\nInput parameter of this SP is to enter a valid BusinessEntityID of the manager from the HumanResources.Employee table"
        + "\n\nFirst table script is - \n\n"
        + TableScript1
        + "\n\n2nd table script is - \n\n"
        + TableScript2
        + "\n\nThird table script is - \n\n"
        + TableScript3
        + "\n\nSQL SP definition is - \n\n"
        + SPScript
        + "\n\nAlso, please provide explanation of SP in simple english."
    )

    Process_text(Question)


# print("EXAMPLE 1 - SUMMARIZING A PDFs")
# Example1_SummarizePDF()

# print("EXAMPLE 2 - Compare two PDFs")
# Exmaple2_ComparePDF()

# print(
#     "EXAMPLE 3 - Turn a business question into sql query, execute query and turn output of query into an email."
# )
# This process is referred as copilot.
# It also demonstrate basic RAG (Retrieval Augmented Generation) implementation
# Example3_Business_question_Scenario()

print(
    "Example 5 - load a SP and associated tables and write a test case based on the loaded artefatcs."
)
Example5_CreateTestCasesFromCode()
