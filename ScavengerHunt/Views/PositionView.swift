//
//  CurrentPositionView.swift
//  ScavengerHunt
//
//  Created by Russell Gordon on 2024-09-30.
//

import CoreLocation
import MapKit
import SwiftUI

struct PositionView: View {
    
    // MARK: Stored properties
    let locationManager = CLLocationManager()
    
    // Initial region to show
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 44.44963,
            longitude: -78.26515
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.01,
            longitudeDelta: 0.01
        )
    )
    
    // Used to track entry to regions
    @State var positionViewModel = PositionViewModel()
    
    // Used to track progress through targets
    @State var targetsViewModel = TargetsViewModel()
    
    // Used to track current answer
    @State var currentAnswer = ""
    
    // MARK: Computed properties
    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow)
            )
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
            }
            .edgesIgnoringSafeArea(.all)

            VStack {
                
                Rectangle()
                    .foregroundStyle(.black)
                    .aspectRatio(1.5/1.0, contentMode: .fit)
                    .overlay {
                        VStack {
                            
                            Spacer()
                            
                            Text("Location manager: \(positionViewModel.location?.description ?? "No Location Provided!")")
                                .foregroundStyle(.white)
                                .padding(.vertical)
                            
                            Text("\(targetsViewModel.getCurrentTarget().question)")
                        }
                        .padding()
                        
                    }
                
                Spacer()
            }
            .edgesIgnoringSafeArea(.all)

        }
        // Show a sheet when we enter the desired region
        .sheet(isPresented: $positionViewModel.shouldShowQuizSheet) {
            
            VStack {
                
                Text("You reached the target!")

                TextField("What is the answer to the question?", text: $currentAnswer)
                
                Button {
                    if currentAnswer.contains( targetsViewModel.getCurrentTarget().answer) {
                        
                        // Mark current target as completed
                        targetsViewModel.targets[targetsViewModel.currentTargetIndex].completed = true
                    }
                } label: {
                    Text("Submit")
                }
                
                if targetsViewModel.targets[targetsViewModel.currentTargetIndex].completed {
                    Image(systemName: "checkmark.seal.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }

            }
            
        }
        .presentationDetents([.medium, .fraction(0.25)])
        .task {
            try? await positionViewModel.requestUserAuthorization()
            await positionViewModel.monitor(
                target: targetsViewModel.getCurrentTarget()
            )
            try? await positionViewModel.startCurrentLocationUpdates()
        }
    }
}

#Preview {
    PositionView()
}
