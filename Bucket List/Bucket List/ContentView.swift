//
//  ContentView.swift
//  Bucket List
//
//  Created by Nikita Novikov on 08.09.2022.
//

import SwiftUI
import MapKit


struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        if viewModel.isUnlocked {
            ZStack {
                Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        VStack {
                            Image(systemName: "star.circle")
                                .resizable()
                                .foregroundColor(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(Circle())
                            
                            Text(location.name)
                                .fixedSize()
                        }
                        .onTapGesture {
                            viewModel.selectedPlace = location
                        }
                    }
                }
                    .ignoresSafeArea()
                
                Circle()
                    .fill(.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)
                
                plusButton
            }
            .sheet(item: $viewModel.selectedPlace) { place in
                EditView(location: place) { newLocation in
                    viewModel.update(location: newLocation)
                }
            }
        } else {
            Button("Unlock Places") {
                self.viewModel.authenticate()
            }
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
    }
    
    private var plusButton: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    viewModel.addLocation()
                } label: {
                    Image(systemName: "plus")
                        .padding()
                        .background(.black.opacity(0.5))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                }
                .padding(.trailing)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
