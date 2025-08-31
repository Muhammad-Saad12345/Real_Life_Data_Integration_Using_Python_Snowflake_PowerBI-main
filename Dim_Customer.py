import random
import csv
from faker import Faker

# Initialize Faker
faker = Faker()

# Ask the user for the number of rows to generate 
nums_rows = int(input("Enter the number of rows you want to generate: "))

# Ask the user for the csv file name
csv_file = input("Enter the name of the CSV file (e.g data.csv): ")

# Define the header (columns) for the csv
header = ['First Name', 'Last Name', 'Gender', 'Date of Birth', 'Email', 'Phone Number', 'Address', 'City', 'State', 'Postal Code', 'Country', 'Loyalty Program ID']

# Open the CSV file for writing
with open(csv_file, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)

    # write the header
    writer.writerow(header)

    # Generate Fake data
    for _ in range(nums_rows):
        row = [
            faker.first_name(),
            faker.last_name(),
            random.choice(['M', 'F']),
            faker.date(),
            faker.email(),
            faker.phone_number(),  
            faker.address().replace("\n", " ").replace(",", " "),
            faker.city(),
            faker.state(),
            faker.postcode(),
            faker.country(),
            random.randint(1, 5)
        ]
        writer.writerow(row)

print(f"{nums_rows} rows of fake data have been written to {csv_file}")
