//
//  TestView.swift
//  BLETest
//
//  Created by Jasjit Singh Chawla on 27/05/21.
//

import SwiftUI
import CoreBluetooth



struct TestView: View {
    
    @ObservedObject var bleManager = BLEManager()
    @State var scanStatus=""
    
    var body: some View {
       
            NavigationView {
                VStack (spacing: 10){
                    Text("Bluetooth Devices")
                        .deepRedTextStyle()
                    List(bleManager.peripherals) {peripheral in
                        NavigationLink(destination: ContentView()){
                            HStack {
                                Text(peripheral.name)
                            }
                            Spacer()
                            Text(String(peripheral.rssi))
                        }
                    }.frame(height:300)
                    Spacer()
                    Text("Status")
                        .headLineStyle()
                    
                    //Status goes here
                    if bleManager.isSwitchedOn {
                        Text("Bluetooth On")
                            .foregroundColor(.green)
                    } else {
                        Text("Bluetooth Off")
                            .foregroundColor(.red)
                    }
                    
                    HStack{
                        VStack (spacing: 10){
                            Button(action: {
                                print("Start Scanning")
                                scanStatus = "Scanning for devices...."
                                self.bleManager.startScanning()
                            }, label: {
                                Text("Start Scanning")
                            })
                            Button(action: {
                                print("Stop Scanning")
                                scanStatus = "Scan stopped"
                                self.bleManager.stopScanning()
                            }, label: {
                                Text("Stop Scanning")
                            })
                        }.padding()
                        
                        Spacer()
                        
                        VStack (spacing: 10){
                            Button(action: {
                                print("Start Advertising")
                            }, label: {
                                Text("Start Advertising")
                            })
                            Button(action: {
                                print("Stop Advertising")
                            }, label: {
                                Text("Stop Advertising")
                            })
                        }.padding()
                    }
                  
                    Text(scanStatus)
                        .captionTextStyle()
                    Spacer()
                }
            }
        
    
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

extension Text{
    func deepRedTextStyle() -> some View {
        self.foregroundColor(.red)
            .italic()
            .opacity(0.7)
            .font(.largeTitle)
            //.frame(width: .infinity, alignment: .center)
    }
    func captionTextStyle() -> some View {
        self.foregroundColor(.secondary)
            .font(.caption)
    }
    func headLineStyle() -> some View {
        self.font(.headline)
    }
}




