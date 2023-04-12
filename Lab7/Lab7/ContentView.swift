//
//  ContentView.swift
//  Lab7
//
//  Created by 贺力 on 3/28/23.
//

import SwiftUI
import CoreLocation

struct Earthquakes: Decodable
{
    let earthquakes:[earthquake]
}

struct earthquake: Decodable
{
    let datetime: String
    let magnitude: Double
}

struct ListData: Codable, Hashable, Identifiable
{
    var id = UUID()
    
    var dateTimeL: String?
    var magnitudeL: Double?
}

struct ContentView: View {
    //@ObservedObject var newsItemVM:ViewModel
    
    @State var cityAddress = ""
    @State var latitudeText = ""
    @State var longitudeText = ""
    @State var dateTime = ""
    @State var magnitude = 0.0
    @State var resultArray:[ListData] = []
    //@State var data:[earthquake] = []
    //@State var earthData:[earthquakeList] = []
    var body: some View {
        NavigationView
        {
            VStack {
                HStack
                {
                    Text("Address: ")
                    TextField("address e.g. New York, NY", text: $cityAddress)
                }
                HStack
                {
                    Button{
                        var geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(cityAddress)
                        {
                            placemarks, error in
                            let placemark = placemarks?.first
                            latitudeText = String(placemark?.location?.coordinate.latitude ?? 0.0)
                            longitudeText = String(placemark?.location?.coordinate.longitude ?? 0.0)
                            print(latitudeText)
                            print(longitudeText)
                            if(resultArray.count > 0)
                            {
                                for i in 0...(resultArray.count)-1
                                {
                                    resultArray.remove(at: i)
                                }
                            }
                        }
                        
                    }label: {
                        Text("Get corrdinates")
                    }
                    Button{
                        getJsonData()
                    }label: {
                        Text("Get information")
                    }
                }
                List{
                    ForEach(resultArray)
                    {
                        item in
                        HStack
                        {
                            Text("Magnitude: \(item.magnitudeL ?? 0.0)")
                            Text("Date Time: \(item.dateTimeL ?? "")")
                        }
                    }
                }
                
            }
            .padding()
        }
    } // end of some View
    
    func getJsonData() {
        let north = String((Double(longitudeText) ?? 0.0) + 10)
        let south = String((Double(longitudeText) ?? 0.0) - 10)
        let west = String((Double(latitudeText) ?? 0.0) - 10)
        let east = String((Double(latitudeText) ?? 0.0) + 10)
        print("north" + String(north))
        
        let urlAsString="http://api.geonames.org/earthquakesJSON?north="+north+"&south="+south+"&east="+east+"&west="+west+"&username=lihe8023"
        //let urlAsString="http://api.geonames.org/earthquakesJSON?north=44.1&south=-9.9&east=-22.4&west=55.2&username=lihe8023"
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            
            do {
                let decodedData = try JSONDecoder().decode(Earthquakes.self, from: data!)
                let count = decodedData.earthquakes.count
                print(count)
                if(count > 10)
                {
                    for i in 0...9
                    {
                        dateTime = decodedData.earthquakes[i].datetime
                        magnitude = decodedData.earthquakes[i].magnitude
                        
                        resultArray.insert(ListData(dateTimeL: dateTime, magnitudeL: magnitude), at: 0)
                    }
                }
                else if(count == 0)
                {
                    resultArray.insert(ListData(dateTimeL: "none", magnitudeL: 0.0), at: 0)
                }
                else
                {
                    for i in 0...(count-1)
                    {
                        
                        dateTime = decodedData.earthquakes[i].datetime
                        magnitude = decodedData.earthquakes[i].magnitude
                        
                        resultArray.insert(ListData(dateTimeL: dateTime, magnitudeL: magnitude), at: 0)
                    }
                }
                
            } catch {
                print("error: \(error)")
            }
        })
        jsonQuery.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
