#CREATING COMPANIES
Company.create(name: "VANDOR TRANS TOURS SRL", email: "office@vandortrans.ro", phone_number: "0762883716", tax_number: "49281782", city: "Gheorgheni", office_address: "Str. Kossuth Lajos nr. 91")
Company.create(name: "PANORAMA TURIST SRL", email: "panorama@gmail.com", phone_number: "0755197688", tax_number: "74112365", city: "Ditrau", office_address: "Str. Dealul frumos 73/A")
Company.create(name: "BALINT TRANS SRL", email: "balinttrans@yahoo.com", phone_number: "0723763998", tax_number: "41549877", city: "Targu Mures", office_address: "Str. Bega nr. 9")
Company.create(name: "TRANSPORT LOCAL SA", email: "office@vandortrans.ro", phone_number: "0763777716", tax_number: "87654782", city: "Targu Mures", office_address: "Str. Bega nr. 2")

#CREATING BUSES FOR THE COMPANIES
vandor = Company.find_by(name: "VANDOR TRANS TOURS SRL")
Bus.create(company_uid: vandor.company_uid, license_plate: "HR49VTT", brand: "Mercedes Integro", manufacturing_year: 2003, capacity: 73, road_tax: Date.parse("2023-12-10"), insurance: Date.parse("2023-12-22"), technical_exam: Date.parse("2023-10-10"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR22VTT", brand: "Setra S516", manufacturing_year: 2009, capacity: 57, road_tax: Date.parse("2024-04-28"), insurance: Date.parse("2024-12-02"), technical_exam: Date.parse("2024-03-03"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR56VTT", brand: "Mercedes Vario", manufacturing_year: 2019, capacity: 45, road_tax: Date.parse("2024-05-21"), insurance: Date.parse("2023-10-22"), technical_exam: Date.parse("2024-11-08"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR67VTT", brand: "Mercedes Vito", manufacturing_year: 2011, capacity: 24, road_tax: Date.parse("2024-06-29"), insurance: Date.parse("2024-01-28"), technical_exam: Date.parse("2024-06-11"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR12VTT", brand: "Otokar Sultan", manufacturing_year: 2011, capacity: 24, road_tax: Date.parse("2024-06-29"), insurance: Date.parse("2024-01-25"), technical_exam: Date.parse("2024-06-11"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR23VTT", brand: "Mercedes Sprinter", manufacturing_year: 2011, capacity: 24, road_tax: Date.parse("2024-06-11"), insurance: Date.parse("2024-06-21"), technical_exam: Date.parse("2023-10-11"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR01VTT", brand: "Mercedes Sprinter", manufacturing_year: 2020, capacity: 28, road_tax: Date.parse("2024-04-21"), insurance: Date.parse("2024-01-22"), technical_exam: Date.parse("2024-01-23"))

panorama = Company.find_by(name: "PANORAMA TURIST SRL")
Bus.create(company_uid: panorama.company_uid, license_plate: "HR34ERT", brand: "Mercedes Sprinter", manufacturing_year: 2010, capacity: 50, road_tax: "2024-01-15", insurance: "2024-01-25", technical_exam: "2024-01-05")
Bus.create(company_uid: panorama.company_uid, license_plate: "HR75RGB", brand: "Mercedes Vario", manufacturing_year: 2012, capacity: 55, road_tax: "2024-02-15", insurance: "2024-02-25", technical_exam: "2024-02-05")
Bus.create(company_uid: panorama.company_uid, license_plate: "HR23UZI", brand: "Mercedes Vario", manufacturing_year: 2015, capacity: 60, road_tax: "2024-03-15", insurance: "2024-03-25",technical_exam: "2024-03-05")
Bus.create(company_uid: panorama.company_uid, license_plate: "HR98GHD", brand: "Setra ComfortClass 500", manufacturing_year: 2018, capacity: 65, road_tax: "2024-04-15", insurance: "2024-04-25", technical_exam: "2024-04-05")
Bus.create(company_uid: panorama.company_uid, license_plate: "HR56LSA", brand: "Volvo B12B", manufacturing_year: 2014, capacity: 70, road_tax: "2024-05-15", insurance: "2024-05-25", technical_exam: "2024-05-05")
Bus.create(company_uid: panorama.company_uid, license_plate: "HR11PAN", brand: "Mercedes Tourismo", manufacturing_year: 2017, capacity: 75, road_tax: "2024-06-15", insurance: "2024-06-25",technical_exam: "2024-06-05")
Bus.create(company_uid: panorama.company_uid, license_plate: "HR14PAN", brand: "Neoplan Starliner", manufacturing_year: 2000, capacity: 80, road_tax: "2024-07-15", insurance: "2024-07-25",technical_exam: "2024-07-05")

balint = Company.find_by(name: "BALINT TRANS SRL")
Bus.create(company_uid: balint.company_uid, license_plate: "MS01CD", brand: "Volvo 9700", manufacturing_year: 2011, capacity: 50, road_tax: "2024-01-15", insurance: "2024-01-25", technical_exam: "2024-01-05")
Bus.create(company_uid: balint.company_uid, license_plate: "MS23OUP", brand: "MAN Lion's Intercity", manufacturing_year: 2013, capacity: 55, road_tax: "2024-02-15", insurance: "2024-02-25", technical_exam: "2024-02-05")
Bus.create(company_uid: balint.company_uid, license_plate: "MS65BTS", brand: "Scania Touring", manufacturing_year: 2006, capacity: 60, road_tax: "2024-03-15", insurance: "2024-03-25",technical_exam: "2024-03-05")
Bus.create(company_uid: balint.company_uid, license_plate: "MS74BTS", brand: "Volvo B12B", manufacturing_year: 2009, capacity: 65, road_tax: "2024-04-15", insurance: "2024-04-25", technical_exam: "2024-04-05")
Bus.create(company_uid: balint.company_uid, license_plate: "MS99WEQ", brand: "Volvo B12B", manufacturing_year: 2014, capacity: 70, road_tax: "2024-05-15", insurance: "2024-05-25", technical_exam: "2024-05-05")
Bus.create(company_uid: balint.company_uid, license_plate: "MS34ALM", brand: "Mercedes Tourismo", manufacturing_year: 2000, capacity: 75, road_tax: "2024-06-15", insurance: "2024-06-25",technical_exam: "2024-06-05")
Bus.create(company_uid: balint.company_uid, license_plate: "MS66ALMROM", brand: "Mercedes Tourismo", manufacturing_year: 2019, capacity: 80, road_tax: "2024-07-15", insurance: "2024-07-25",technical_exam: "2024-07-05")


transloc = Company.find_by(name: "TRANSPORT LOCAL SA")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS23TGM", brand: "Volvo 9700", manufacturing_year: 2010, capacity: 50, road_tax: "2024-01-15", insurance: "2024-01-25", technical_exam: "2024-01-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS34TGM", brand: "MAN Lion's Intercity", manufacturing_year: 2012, capacity: 55, road_tax: "2024-02-15", insurance: "2024-02-25", technical_exam: "2024-02-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS98TGM", brand: "Mercedes Integro", manufacturing_year: 2015, capacity: 60, road_tax: "2024-03-15", insurance: "2024-03-25",technical_exam: "2024-03-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS12TGM", brand: "Mercedes Integro", manufacturing_year: 2011, capacity: 65, road_tax: "2024-04-15", insurance: "2024-04-25", technical_exam: "2024-04-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS23MUI", brand: "Volvo B12B", manufacturing_year: 2011, capacity: 70, road_tax: "2024-05-15", insurance: "2024-05-25", technical_exam: "2024-05-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS22UZI", brand: "Mercedes Tourismo", manufacturing_year: 2017, capacity: 75, road_tax: "2024-06-15", insurance: "2024-06-25",technical_exam: "2024-06-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS33ALS", brand: "Neoplan Starliner", manufacturing_year: 2019, capacity: 80, road_tax: "2024-01-15", insurance: "2024-07-25",technical_exam: "2024-07-05")


#CREATING ADMINS FOR THE COMPANIES
Admin.create(company_uid: vandor.company_uid, email: "office@vandortrans.ro", firstname: "Elemér", lastname: "Kecskeméti", role: "boss", phone_number: "0728493883", address: "Com. Joseni str. Principala nr. 19", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "hompoth.krisztian@gmail.com", firstname: "Krisztián", lastname: "Orsós", role: "manager", phone_number: "0761837888", address: "Com. Joseni str. Faluköze nr. 1", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "csatabela@gmail.com", firstname: "Béla", lastname: "Csata", role: "driver", phone_number: "0752358475", address: "Mun. Gheorgheni str. Ghindei nr. 1", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "magdi92@gmail.com", firstname: "Magdolna", lastname: "Kovács", role: "driver", phone_number: "0739489586", address: "Mun. Gheorgheni str. Stadionului nr. 4", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "orsospista11@gmail.com", firstname: "István", lastname: "Orsós", role: "driver", phone_number: "0755928111", address: "Com. Ciumani str. Inczelaka nr. 1398", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "ninjanarch@yahoo.com", firstname: "Iván", lastname: "Elekes", role: "driver", phone_number: "0724889734", address: "Com. Ciumani str. Principala nr. 12", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "karoly_elekes@gmail.com", firstname: "Károly", lastname: "Elekes", role: "driver", phone_number: "0745399324", address: "Com. Suseni str. Kéthíd nr. 198", password: "aaaaaa", password_confirmation: "aaaaaa")

Admin.create(company_uid: balint.company_uid, email: "office@balinttrans.ro", firstname: "Elemér", lastname: "Kecskeméti", role: "boss", phone_number: "0728493883", address: "Com. Joseni str. Principala nr. 19", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: balint.company_uid, email: "hompoth.krisztian@gmail.com", firstname: "Krisztián", lastname: "Orsós", role: "manager", phone_number: "0761837888", address: "Com. Joseni str. Faluköze nr. 1", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: balint.company_uid, email: "csatabela@gmail.com", firstname: "Béla", lastname: "Csata", role: "driver", phone_number: "0752358475", address: "Mun. Gheorgheni str. Ghindei nr. 1", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: balint.company_uid, email: "magdi92@gmail.com", firstname: "Magdolna", lastname: "Kovács", role: "driver", phone_number: "0739489586", address: "Mun. Gheorgheni str. Stadionului nr. 4", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: balint.company_uid, email: "orsospista11@gmail.com", firstname: "István", lastname: "Orsós", role: "driver", phone_number: "0755928111", address: "Com. Ciumani str. Inczelaka nr. 1398", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: balint.company_uid, email: "ninjanarch@yahoo.com", firstname: "Iván", lastname: "Elekes", role: "driver", phone_number: "0724889734", address: "Com. Ciumani str. Principala nr. 12", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: balint.company_uid, email: "karoly_elekes@gmail.com", firstname: "Károly", lastname: "Elekes", role: "driver", phone_number: "0745399324", address: "Com. Suseni str. Kéthíd nr. 198", password: "aaaaaa", password_confirmation: "aaaaaa")

Admin.create(company_uid: panorama.company_uid, email: "office@panoramatrans.ro", firstname: "Elemér", lastname: "Kecskeméti", role: "boss", phone_number: "0728493883", address: "Com. Joseni str. Principala nr. 19", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: panorama.company_uid, email: "hompoth.krisztian@gmail.com", firstname: "Krisztián", lastname: "Orsós", role: "manager", phone_number: "0761837888", address: "Com. Joseni str. Faluköze nr. 1", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: panorama.company_uid, email: "csatabela@gmail.com", firstname: "Béla", lastname: "Csata", role: "driver", phone_number: "0752358475", address: "Mun. Gheorgheni str. Ghindei nr. 1", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: panorama.company_uid, email: "magdi92@gmail.com", firstname: "Magdolna", lastname: "Kovács", role: "driver", phone_number: "0739489586", address: "Mun. Gheorgheni str. Stadionului nr. 4", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: panorama.company_uid, email: "orsospista11@gmail.com", firstname: "István", lastname: "Orsós", role: "driver", phone_number: "0755928111", address: "Com. Ciumani str. Inczelaka nr. 1398", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: panorama.company_uid, email: "ninjanarch@yahoo.com", firstname: "Iván", lastname: "Elekes", role: "driver", phone_number: "0724889734", address: "Com. Ciumani str. Principala nr. 12", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: panorama.company_uid, email: "karoly_elekes@gmail.com", firstname: "Károly", lastname: "Elekes", role: "driver", phone_number: "0745399324", address: "Com. Suseni str. Kéthíd nr. 198", password: "aaaaaa", password_confirmation: "aaaaaa")

Admin.create(company_uid: transloc.company_uid, email: "office@transloctrans.ro", firstname: "Elemér", lastname: "Kecskeméti", role: "boss", phone_number: "0728493883", address: "Com. Joseni str. Principala nr. 19", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "hompoth.krisztian@gmail.com", firstname: "Krisztián", lastname: "Orsós", role: "manager", phone_number: "0761837888", address: "Com. Joseni str. Faluköze nr. 1", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "csatabela@gmail.com", firstname: "Béla", lastname: "Csata", role: "driver", phone_number: "0752358475", address: "Mun. Gheorgheni str. Ghindei nr. 1", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "magdi92@gmail.com", firstname: "Magdolna", lastname: "Kovács", role: "driver", phone_number: "0739489586", address: "Mun. Gheorgheni str. Stadionului nr. 4", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "orsospista11@gmail.com", firstname: "István", lastname: "Orsós", role: "driver", phone_number: "0755928111", address: "Com. Ciumani str. Inczelaka nr. 1398", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "ninjanarch@yahoo.com", firstname: "Iván", lastname: "Elekes", role: "driver", phone_number: "0724889734", address: "Com. Ciumani str. Principala nr. 12", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "karoly_elekes@gmail.com", firstname: "Károly", lastname: "Elekes", role: "driver", phone_number: "0745399324", address: "Com. Suseni str. Kéthíd nr. 198", password: "aaaaaa", password_confirmation: "aaaaaa")

#CREATING USERS
User.create(email: "attila.zsigmond2002@gmail.com", firstname: "Attila", lastname: "Zsigmond", provider: "email", phone_number:"0752358475", language: "hu")
User.create(email: "portik.szabolcs@gmail.com", firstname: "Szabolcs", lastname: "Portik", provider: "email", phone_number:"0732766587", language: "hu")
User.create(email: "bodobalint01@gmail.com", firstname: "Bálint", lastname: "Bodó", provider: "email", phone_number:"0752358475", language: "hu")

#CREATING STATIONS
Station.create(name: "Csomafalva központ", latitude: 46.6791797, longitude: 25.515264, city: "Ciumani", address: "Str. Principala nr. 89")
Station.create(name: "Csomafalva szászfalu", latitude: 46.6729104, longitude: 25.4547497, city: "Ciumani", address: "Str. Tötés nr. 18")
Station.create(name: "Alfalu központ", latitude: 6.7002046, longitude: 25.493437, city: "Joseni", address: "Str. Ciumani nr. 88")
Station.create(name: "Alfalu lengyár", latitude: 46.70528, longitude: 25.5151177, city: "Joseni", address: "Str. Gheorgheni nr. 3")
Station.create(name: "Gyergyó állomás", latitude: 46.7164726, longitude: 25.5679183, city: "Gheorgheni", address: "Str. Garii nr. 16")
Station.create(name: "Gyergyó Maros hotel", latitude: 46.7209535, longitude: 25.5823401, city: "Gheorgheni", address: "Bul. Fratiei nr. 65")


