#CREATING COMPANIES
Company.create(name: "VANDOR TRANS TOURS SRL", email: "office@vandortrans.ro", phone_number: "0762883716", tax_number: "49281782", city: "Gheorgheni", office_address: "Str. Kossuth Lajos nr. 91")
Company.create(name: "TRANSPORT LOCAL SA", email: "office@vandortrans.ro", phone_number: "0763777716", tax_number: "87654782", city: "Targu Mures", office_address: "Str. Bega nr. 2")
Company.create(name: "TESZT CÉG", email: "teszt@bus4u.ro", phone_number: "0755555555", tax_number: "27488344", city: "Seholvaros", office_address: "Str. asdasd")

#CREATING BUSES FOR THE COMPANIES
vandor = Company.find_by(name: "VANDOR TRANS TOURS SRL")
Bus.create(company_uid: vandor.company_uid, license_plate: "HR49VTT", brand: "Mercedes Integro", manufacturing_year: 2003, capacity: 73, road_tax: Date.parse("2023-12-10"), insurance: Date.parse("2023-12-22"), technical_exam: Date.parse("2023-10-10"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR22VTT", brand: "Setra S516", manufacturing_year: 2009, capacity: 57, road_tax: Date.parse("2024-04-28"), insurance: Date.parse("2024-12-02"), technical_exam: Date.parse("2024-03-03"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR56VTT", brand: "Mercedes Vario", manufacturing_year: 2019, capacity: 45, road_tax: Date.parse("2024-05-21"), insurance: Date.parse("2023-10-22"), technical_exam: Date.parse("2024-11-08"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR67VTT", brand: "Mercedes Vito", manufacturing_year: 2011, capacity: 24, road_tax: Date.parse("2024-06-29"), insurance: Date.parse("2024-01-28"), technical_exam: Date.parse("2024-06-11"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR12VTT", brand: "Otokar Sultan", manufacturing_year: 2011, capacity: 24, road_tax: Date.parse("2024-06-29"), insurance: Date.parse("2024-01-25"), technical_exam: Date.parse("2024-06-11"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR23VTT", brand: "Mercedes Sprinter", manufacturing_year: 2011, capacity: 24, road_tax: Date.parse("2024-06-11"), insurance: Date.parse("2024-06-21"), technical_exam: Date.parse("2023-10-11"))
Bus.create(company_uid: vandor.company_uid, license_plate: "HR01VTT", brand: "Mercedes Sprinter", manufacturing_year: 2020, capacity: 28, road_tax: Date.parse("2024-04-21"), insurance: Date.parse("2024-01-22"), technical_exam: Date.parse("2024-01-23"))

transloc = Company.find_by(name: "TRANSPORT LOCAL SA")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS23TGM", brand: "Volvo 9700", manufacturing_year: 2010, capacity: 50, road_tax: "2024-01-15", insurance: "2024-01-25", technical_exam: "2024-01-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS34TGM", brand: "MAN Lion's Intercity", manufacturing_year: 2012, capacity: 55, road_tax: "2024-02-15", insurance: "2024-02-25", technical_exam: "2024-02-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS98TGM", brand: "Mercedes Integro", manufacturing_year: 2015, capacity: 60, road_tax: "2024-03-15", insurance: "2024-03-25",technical_exam: "2024-03-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS12TGM", brand: "Mercedes Integro", manufacturing_year: 2011, capacity: 65, road_tax: "2024-04-15", insurance: "2024-04-25", technical_exam: "2024-04-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS23MUI", brand: "Volvo B12B", manufacturing_year: 2011, capacity: 70, road_tax: "2024-05-15", insurance: "2024-05-25", technical_exam: "2024-05-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS22UZI", brand: "Mercedes Tourismo", manufacturing_year: 2017, capacity: 75, road_tax: "2024-06-15", insurance: "2024-06-25",technical_exam: "2024-06-05")
Bus.create(company_uid: transloc.company_uid, license_plate: "MS33ALS", brand: "Neoplan Starliner", manufacturing_year: 2019, capacity: 80, road_tax: "2024-01-15", insurance: "2024-07-25",technical_exam: "2024-07-05")


#CREATING ADMINS FOR THE COMPANIES
Admin.create(company_uid: vandor.company_uid, email: "office@vandortrans.ro", firstname: "Elemér", lastname: "Kecskeméti", role: "boss", phone_number: "0728493883", address: "Com. Joseni str. Principala nr. 19", password: "aaaaaaaa", password_confirmation: "aaaaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "hompoth.krisztian@gmail.com", firstname: "Krisztián", lastname: "Orsós", role: "manager", phone_number: "0761837888", address: "Com. Joseni str. Faluköze nr. 1", password: "aaaaaaaa", password_confirmation: "aaaaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "csatabela@gmail.com", firstname: "Béla", lastname: "Csata", role: "driver", phone_number: "0752358475", address: "Mun. Gheorgheni str. Ghindei nr. 1", password: "aaaaaaaa", password_confirmation: "aaaaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "magdi92@gmail.com", firstname: "Magdolna", lastname: "Kovács", role: "driver", phone_number: "0739489586", address: "Mun. Gheorgheni str. Stadionului nr. 4", password: "aaaaaaaa", password_confirmation: "aaaaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "orsospista11@gmail.com", firstname: "István", lastname: "Orsós", role: "driver", phone_number: "0755928111", address: "Com. Ciumani str. Inczelaka nr. 1398", password: "aaaaaaaa", password_confirmation: "aaaaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "ninjanarch@yahoo.com", firstname: "Iván", lastname: "Elekes", role: "driver", phone_number: "0724889734", address: "Com. Ciumani str. Principala nr. 12", password: "aaaaaaaa", password_confirmation: "aaaaaaaa")
Admin.create(company_uid: vandor.company_uid, email: "karoly_elekes@gmail.com", firstname: "Károly", lastname: "Elekes", role: "driver", phone_number: "0745399324", address: "Com. Suseni str. Kéthíd nr. 198", password: "aaaaaaaa", password_confirmation: "aaaaaaaa")

Admin.create(company_uid: transloc.company_uid, email: "office@transloctrans.ro", firstname: "Elemér", lastname: "Kecskeméti", role: "boss", phone_number: "0728493883", address: "Com. Joseni str. Principala nr. 19", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "hompoth.krisztian2@gmail.com", firstname: "Krisztián", lastname: "Orsós", role: "manager", phone_number: "0761837888", address: "Com. Joseni str. Faluköze nr. 1", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "csatabela2@gmail.com", firstname: "Béla", lastname: "Csata", role: "driver", phone_number: "0752358475", address: "Mun. Gheorgheni str. Ghindei nr. 1", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "magdi922@gmail.com", firstname: "Magdolna", lastname: "Kovács", role: "driver", phone_number: "0739489586", address: "Mun. Gheorgheni str. Stadionului nr. 4", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "orsospista112@gmail.com", firstname: "István", lastname: "Orsós", role: "driver", phone_number: "0755928111", address: "Com. Ciumani str. Inczelaka nr. 1398", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "ninjanarc2h@yahoo.com", firstname: "Iván", lastname: "Elekes", role: "driver", phone_number: "0724889734", address: "Com. Ciumani str. Principala nr. 12", password: "aaaaaa", password_confirmation: "aaaaaa")
Admin.create(company_uid: transloc.company_uid, email: "2@gmail.com", firstname: "Károly", lastname: "Elekes", role: "driver", phone_number: "0745399324", address: "Com. Suseni str. Kéthíd nr. 198", password: "aaaaaa", password_confirmation: "aaaaaa")

Admin.create(company_uid: tesztceg.company_uid, email: "teszt@bus4u.com", firstname: "Teszt", lastname: "Teszt", role: "boss", phone_number: "0728493883", address: "asdasd str. afjei", password: "bus4u@teszt", password_confirmation: "bus4u@teszt")

#CREATING CITIES
ciumani = City.create(name: "Gyergyócsomafalva", zip_code: "537050")
joseni = City.create(name: "Gyergyóalfalu", zip_code: "537150")
gheorgheni = City.create(name: "Gyergyószentmiklós", zip_code: "117050")
tgm = City.create(name: "Marosvásárhely", zip_code: "129138")
praid = City.create(name: "Parajd", zip_code: "382983")

#CREATING STATIONS
s1 = Station.create(name: "Csomafalva Központ", latitude: 46.6791586975964, longitude: 25.51624828632996, city: ciumani, address: "Str. Principala nr. 89")
Station.create(name: "Csomafalva Szászfalu", latitude: 46.67291081146523, longitude: 25.49966790502754, city: ciumani, address: "Str. Töltés nr. 18")
Station.create(name: "Alfalu Központ", latitude: 46.701383449930674, longitude: 25.504336705477453, city: joseni, address: "Str. Ciumani nr. 88")
s2 = Station.create(name: "Alfalu Lengyár", latitude: 46.7061202738582, longitude: 25.527403454222306, city: joseni, address: "Str. Gheorgheni nr. 3")
Station.create(name: "Gyergyó Állomás", latitude: 46.719521757528696, longitude: 25.5740503955354, city: gheorgheni, address: "Str. Garii nr. 16")
Station.create(name: "Gyergyó Maros hotel", latitude: 46.722678965669736, longitude: 25.59475044928773, city: gheorgheni, address: "Bul. Fratiei nr. 65")
Station.create(name: "Gyergyó Központ", latitude: 46.720802603020786, longitude: 25.599988435400288, city: gheorgheni, address: "Pta. Libertatii nr. 26")

Station.create(name: "Parajd központ", latitude: 46.55101414841867, longitude: 25.126586221716337, city: praid, address: "Str. principala nr. 23")


Station.create(name: "Aleea Carpați 1",       latitude: 46.556736, longitude: 24.563466, city: tgm, address: "")
Station.create(name: "Aleea Carpați 2",       latitude: 46.553075, longitude: 24.557469, city: tgm, address: "")
Station.create(name: "Autogara Voiajor 1",    latitude: 46.528639, longitude: 24.545934, city: tgm, address: "")
Station.create(name: "Autogara Voiajor 2",    latitude: 46.527589, longitude: 24.543129, city: tgm, address: "")
Station.create(name: "Avram Iancu",          latitude: 46.536222, longitude: 24.558496, city: tgm, address: "")
Station.create(name: "B-Dul 1dec.1918",      latitude: 46.534737, longitude: 24.583942, city: tgm, address: "")
Station.create(name: "Bușteni",             latitude: 46.538794, longitude: 24.575232, city: tgm, address: "")
Station.create(name: "Cardinal Iuliu Hossu", latitude: 46.541185, longitude: 24.555683, city: tgm, address: "")
Station.create(name: "Calea Sighișoarei",     latitude: 46.527499, longitude: 24.559840, city: tgm, address: "")
Station.create(name: "Chimie",              latitude: 46.518236, longitude: 24.523731, city: tgm, address: "")
Station.create(name: "Ciucaș",              latitude: 46.528929, longitude: 24.553965, city: tgm, address: "")
Station.create(name: "Crinului",            latitude: 46.537467, longitude: 24.558459, city: tgm, address: "")
Station.create(name: "Cireșului",           latitude: 46.535330, longitude: 24.558592, city: tgm, address: "")
Station.create(name: "Cocoșul De Aur",      latitude: 46.550621, longitude: 24.556054, city: tgm, address: "")
Station.create(name: "Conserve",            latitude: 46.518516, longitude: 24.524824, city: tgm, address: "")
Station.create(name: "Cosmos",              latitude: 46.532712, longitude: 24.559066, city: tgm, address: "")
Station.create(name: "Cuza Vodă",           latitude: 46.546265, longitude: 24.554488, city: tgm, address: "")
Station.create(name: "Corina 1",            latitude: 46.533259, longitude: 24.588341, city: tgm, address: "")
Station.create(name: "Corina 2",            latitude: 46.532554, longitude: 24.589818, city: tgm, address: "")
Station.create(name: "Darina",              latitude: 46.553687, longitude: 24.558339, city: tgm, address: "")
Station.create(name: "Dâmbul Pietros",      latitude: 46.531885, longitude: 24.557522, city: tgm, address: "")
Station.create(name: "Decebal",             latitude: 46.558816, longitude: 24.546225, city: tgm, address: "")
Station.create(name: "Dedeman",             latitude: 46.5269, longitude: 24.599376, city: tgm, address: "")
Station.create(name: "Electrica",           latitude: 46.55046, longitude: 24.555854, city: tgm, address: "")
Station.create(name: "Electromureș",        latitude: 46.552943, longitude: 24.551853, city: tgm, address: "")
Station.create(name: "Evidenta Populației", latitude: 46.547617, longitude: 24.560497, city: tgm, address: "")
Station.create(name: "Evreilor Martiri",    latitude: 46.548274, longitude: 24.558367, city: tgm, address: "")
Station.create(name: "European Retail Park", latitude: 46.511488, longitude: 24.510914, city: tgm, address: "")
Station.create(name: "Europa",              latitude: 46.53865, longitude: 24.569996, city: tgm, address: "")
Station.create(name: "Fortuna",             latitude: 46.535606, longitude: 24.582837, city: tgm, address: "")
Station.create(name: "Gara Cfr",            latitude: 46.780569, longitude: 24.718989, city: tgm, address: "")
Station.create(name: "Grand",               latitude: 46.541837, longitude: 24.557862, city: tgm, address: "")
Station.create(name: "Hotel Business",      latitude: 46.526547, longitude: 24.599381, city: tgm, address: "")
Station.create(name: "Iuliu Maniu",        latitude: 46.541462, longitude: 24.555781, city: tgm, address: "")
Station.create(name: "Izvoru Rece",        latitude: 46.534833, longitude: 24.565719, city: tgm, address: "")
Station.create(name: "Izvor",              latitude: 46.539685, longitude: 24.560505, city: tgm, address: "")
Station.create(name: "Liceul Electromureș", latitude: 46.534134, longitude: 24.590571, city: tgm, address: "")
Station.create(name: "Macul Rosu",         latitude: 46.535531, longitude: 24.575505, city: tgm, address: "")
Station.create(name: "Mari Cristi",        latitude: 46.533244, longitude: 24.578363, city: tgm, address: "")
Station.create(name: "Matei Corvin",       latitude: 46.549909, longitude: 24.554209, city: tgm, address: "")
Station.create(name: "Metro 1",           latitude: 46.515225, longitude: 24.518314, city: tgm, address: "")
Station.create(name: "Metro 2",            latitude: 46.515516, longitude: 24.518314, city: tgm, address: "")
Station.create(name: "Moldovei",           latitude: 46.535385, longitude: 24.578868, city: tgm, address: "")
Station.create(name: "Olimp",              latitude: 46.530169, longitude: 24.555978, city: tgm, address: "")
Station.create(name: "Panduru - Mol",      latitude: 46.53363, longitude: 24.570617, city: tgm, address: "")
Station.create(name: "Panduru",           latitude: 46.533485, longitude: 24.570685, city: tgm, address: "")
Station.create(name: "Pandurilor",        latitude: 46.789436, longitude: 24.711702, city: tgm, address: "")
Station.create(name: "Petrila",           latitude: 46.538029, longitude: 24.558625, city: tgm, address: "")
Station.create(name: "Piața De Zi",       latitude: 46.546315, longitude: 24.554655, city: tgm, address: "")
Station.create(name: "Piața Diamant 1",   latitude: 46.53731,  longitude: 24.590374, city: tgm, address: "")
Station.create(name: "Piața Diamant 2",   latitude: 46.536702, longitude: 24.591245, city: tgm, address: "")
Station.create(name: "Piața Teatrului",   latitude: 46.545688, longitude: 24.562013, city: tgm, address: "")
Station.create(name: "Piața Trandafirilor", latitude: 46.543731, longitude: 24.560226, city: tgm, address: "")
Station.create(name: "Piața Unirii",      latitude: 46.562757, longitude: 24.547926, city: tgm, address: "")
Station.create(name: "Plopilor",         latitude: 46.56485,  longitude: 24.551579, city: tgm, address: "")
Station.create(name: "Poli 2",           latitude: 46.53941,  longitude: 24.560966, city: tgm, address: "")
Station.create(name: "Podul Mureș",      latitude: 46.556406, longitude: 24.546366, city: tgm, address: "")
Station.create(name: "Predeal",          latitude: 46.536772, longitude: 24.561853, city: tgm, address: "")
Station.create(name: "Prodcomplex",      latitude: 46.524877, longitude: 24.537686, city: tgm, address: "")
Station.create(name: "Record 1",         latitude: 46.521784, longitude: 24.531423, city: tgm, address: "")
Station.create(name: "Record 2",         latitude: 46.521911, longitude: 24.531195, city: tgm, address: "")
Station.create(name: "Radio Târgu Mureș", latitude: 46.53906, longitude: 24.576314, city: tgm, address: "")
Station.create(name: "Regele Ferdinand", latitude: 46.534265, longitude: 24.591589, city: tgm, address: "")
Station.create(name: "Sala Polivalenta", latitude: 46.549988, longitude: 24.553958, city: tgm, address: "")
Station.create(name: "Sălăgean",           latitude: 46.761508, longitude: 24.636575, city: tgm, address: "")
Station.create(name: "Sapientia",        latitude: 46.52338, longitude: 24.599079, city: tgm, address: "")
Station.create(name: "Shopping City",     latitude: 46.528258, longitude: 24.596567, city: tgm, address: "")
Station.create(name: "Ștrandul 1 Mai",    latitude: 46.55717, longitude: 24.564441, city: tgm, address: "")
Station.create(name: "Tisei",             latitude: 46.557507, longitude: 24.547822, city: tgm, address: "")
Station.create(name: "Trecătorul",        latitude: 46.531056, longitude: 24.549755, city: tgm, address: "")
Station.create(name: "Traian Vuia",       latitude: 46.524789, longitude: 24.537001, city: tgm, address: "")
Station.create(name: "Tudor Vladimirescu", latitude: 46.539028, longitude: 24.586671, city: tgm, address: "")
Station.create(name: "Voinicenilor",       latitude: 46.559763, longitude: 24.548363, city: tgm, address: "")

#CREATE A ROUTE
Route.create(name: "Szászfalu-Gyergyó", company_uid: vandor.company_uid, nr_of_stations: 10, basic_fare: 0);
Route.create(name: "Gyergyó-Marosvásárhely", company_uid: vandor.company_uid, nr_of_stations: 8, basic_fare: 0);

Route.create(name: "22 - European Retail Park - Shopping City", company_uid: transloc.company_uid, nr_of_stations: 26, basic_fare: 2);
Route.create(name: "26 - Sapientia - Aleea Carpati", company_uid: transloc.company_uid, nr_of_stations: 32, basic_fare: 2);
Route.create(name: "27 - Sapientia - Spitalul Județean", company_uid: transloc.company_uid, nr_of_stations: 30, basic_fare: 2);
Route.create(name: "32 - Shopping City - Unirii", company_uid: transloc.company_uid, nr_of_stations: 25, basic_fare: 2);
Route.create(name: "44 - Sapientia - Combinat", company_uid: transloc.company_uid, nr_of_stations: 47, basic_fare: 2);

route_22 = Route.find_by(name: "22 - European Retail Park - Shopping City")

stations = [
  "Shopping City",
  "Corina 1",
  "Pandurilor",
  "Mari Cristi",
  "Panduru - Mol",
  "Calea Sighișoarei",
  "Gara Cfr",
  "Autogara Voiajor 2",
  "Traian Vuia",
  "Record 2",
  "Chimie",
  "Metro 2",
  "European Retail Park",
  "European Retail Park",
  "Metro 1",
  "Conserve",
  "Record 1",
  "Prodcomplex",
  "Autogara Voiajor 1",
  "Trecătorul",
  "Calea Sighișoarei",
  "Panduru",
  "Mari Cristi",
  "B-Dul 1dec.1918",
  "Corina 2",
  "Shopping City"
]

stations.each_with_index do |station_name, index|
  RouteStation.create(route: route_22, station: Station.find_by(name: station_name), sequence: index + 1)
end

route_26 = Route.find_by(name: "26 - Sapientia - Aleea Carpati")

stations_26 = [
  "Sapientia",
  "Dedeman",
  "Regele Ferdinand",
  "Piața Diamant 1",
  "Înfrățirii",
  "Fortuna",
  "Radio Târgu Mureș",
  "Izvor",
  "Grand",
  "Piața Trandafirilor",
  "Evidenta Populaţiei",
  "Cocoșul De Aur",
  "Aleea Carpați 2",
  "Ștrandul 1 Mai",
  "Ștrandul 1 Mai",
  "Aleea Carpați 1",
  "Darina",
  "Electromureș",
  "Electrica",
  "Evreilor Martiri",
  "Piața Teatrului",
  "Poli 2",
  "Europa",
  "Bușteni",
  "Poklos",
  "Tudor Vladimirescu",
  "Piața Diamant 2",
  "Liceul Electromureș",
  "Corina 2",
  "Shopping City",
  "Hotel Business",
  "Sapientia"
]

stations_26.each_with_index do |station_name, index|
  RouteStation.create(route: route_26, station: Station.find_by(name: station_name), sequence: index + 1)
end

route_27 = Route.find_by(name: "27 - Sapientia - Spitalul Județean")

stations_27 = [
  "Sapientia",
  "Dedeman",
  "Corina 1",
  "Pandurilor",
  "Mari Cristi",
  "Panduru - Mol",
  "Izvoru Rece",
  "Predeal",
  "Crinului",
  "Grand",
  "Piața Trandafirilor",
  "Revoluţiei",
  "P-Ța Republicii",
  "22 Decembrie 1989",
  "Spitalul Județean",
  "Parcul Eroilor",
  "Clinica De Oncologie",
  "Braseria Universității",
  "Nicolae Iorga",
  "Piața Teatrului",
  "Poli 2",
  "Izvoru Rece",
  "Panduru",
  "Mari Cristi",
  "B-Dul 1dec.1918",
  "Corina 2",
  "Shopping City",
  "Hotel Business",
  "Sapientia"
]

stations_27.each_with_index do |station_name, index|
  RouteStation.create(route: route_27, station: Station.find_by(name: station_name), sequence: index + 1)
end

route_32 = Route.find_by(name: "32 - Shopping City - Unirii")             

stations_32 = [
  "Shopping City",
  "Corina 1",
  "Fortuna",
  "Radio Târgu Mureș",
  "Izvor",
  "Cardinal Iuliu Hossu",
  "Piața De Zi",
  "Matei Corvin",
  "Tisei",
  "Voinicenilor",
  "Piața Unirii",
  "Plopilor",
  "Plopilor",
  "Unirii 1",
  "Decebal",
  "Podul Mureș",
  "Sala Polivalenta",
  "Cuza Vodă",
  "Iuliu Maniu",
  "Poli 2",
  "Europa",
  "Bușteni",
  "B-Dul 1dec.1918",
  "Corina 2",
  "Shopping City"
]

stations_32.each_with_index do |station_name, index|
  RouteStation.create(route: route_32, station: Station.find_by(name: station_name), sequence: index + 1)
end

route_44 = Route.find_by(name: "44 - Sapientia - Combinat")

stations_44 = [
  "European Retail Park",
  "Metro 1",
  "Conserve",
  "Record 1",
  "Prodcomplex",
  "Autogara Voiajor 1",
  "Trecătorul",
  "Olimp",
  "Cosmos",
  "Avram Iancu",
  "Petrila",
  "Predeal",
  "Izvoru Rece",
  "Panduru",
  "Macul Rosu",
  "Moldovei",
  "Poklos",
  "Tudor Vladimirescu",
  "Piața Diamant 2",
  "Liceul Electromureș",
  "Corina 2",
  "Shopping City",
  "Hotel Business",
  "Sapientia",
  "Sapientia",
  "Dedeman",
  "Regele Ferdinand",
  "Piața Diamant 1",
  "Înfrățirii",
  "Fortuna",
  "Moldovei",
  "Macul Rosu",
  "Panduru - Mol",
  "Izvoru Rece",
  "Predeal",
  "Crinului",
  "Cireșului",
  "Dâmbul Pietros",
  "Ciucaș",
  "Gara Cfr",
  "Autogara Voiajor 2",
  "Traian Vuia",
  "Record 2",
  "Chimie",
  "Metro 2",
  "Combinat",
  "European Retail Park"
]

stations_44.each_with_index do |station_name, index|
  RouteStation.create(route: route_44, station: Station.find_by(name: station_name), sequence: index + 1)
end