//
//  CitySelectionView.swift
//  TravelSchedule
//
//  Created by Roman Romanov on 28.11.2024.
//

import SwiftUI

struct CitySelectionView: View {
    
    // MARK: - Properties
    
    @Binding var stationData: String
    @Binding var isShowRoot: Bool
    
    let cities = ["Mосква", "Санкт-Петербург", "Сочи", "Горный воздух", "Краснодар", "Казань", "Омск"]
    @State private var searchText: String = ""
    
    @StateObject private var viewModel = CitySelectionViewModel()
    
    var searchResult: [String] {
        guard !searchText.isEmpty else { return cities }
        return cities.filter { $0.contains(searchText) }
    }
    
    var body: some View {
        ZStack {
            AppColorSettings.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            cityList
            
            customPlaceholder(
                placeholder: Text("City not found"),
                isVisible: searchResult.isEmpty
            )
        }
        .navigationDestination(isPresented: $viewModel.isCitySelected) {
            StationSelectorView(
                stationData: $stationData,
                city: $viewModel.citySelected,
                isShowRoot: $viewModel.isCitySelected
            )
        }
        .navigationTitle("City selection")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .backButtonToolbarItem(isShowRoot: $isShowRoot)
    }
}

extension CitySelectionView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let rowHeight: CGFloat = 60
    }
    
    // MARK: - cityList
    
    private var cityList: some View {
        List(searchResult, id: \.self) { city in
            HStack {
                Button(
                    action: { selectCity(city) },
                    label: {
                        Text(city)
                            .font(AppConstants.fontRegular17)
                    }
                )
                Spacer()
                Image(systemName: AppImages.cityListBadge)
            }
            .listRowSeparator(.hidden)
            .frame(height: Constants.rowHeight)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Enter your query")
    }
    
    // MARK: - selectCity
    
    func selectCity(_ city: String) {
        viewModel.selectCity(city)
    }
}

final class CitySelectionViewPreview: ObservableObject {
    @State var stationData = ""
    @State var isShowRoot: Bool = true
}

#Preview {
    let params = CitySelectionViewPreview()
    NavigationStack {
        CitySelectionView(
            stationData: params.$stationData,
            isShowRoot: params.$isShowRoot
        )
    }
}
