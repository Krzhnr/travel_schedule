//
//  StoriesView.swift
//  TravelSchedule
//
//  Created by Roman Romanov on 06.12.2024.
//

import SwiftUI

struct StoriesView: View {
    
    // MARK: - Properties
    
    let stories: [StoryData]
    @Binding var showStory: Bool
    @Binding var currentStoryIndex: Int
    
    @StateObject private var model: StoriesViewModel
    
    // MARK: - init
    
    init(stories: [StoryData], showStory: Binding<Bool>, currentStoryIndex: Binding<Int>) {
        self.stories = stories
        self._showStory = showStory
        self._currentStoryIndex = currentStoryIndex
        
        let timerConfiguration: TimerConfiguration = TimerConfiguration(storiesCount: stories.count)
        self._model = StateObject(wrappedValue: StoriesViewModel(timerConfiguration: timerConfiguration))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            StoriesTabView(stories: stories, currentStoryIndex: $currentStoryIndex)
                .onChange(of: currentStoryIndex) { newValue in
                    withAnimation {
                        model.saveStoryIndex(currentValue: currentStoryIndex, newValue: newValue)
                    }
                }
                .onTapGesture {
                    model.nextStory(
                            currentStoryIndex: currentStoryIndex,
                            storiesCount: stories.count
                        )
                }
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            if
                                value.translation.height < 30
                                || value.translation.height > 30
                            {
                                closeStory()
                            }
                        }
                )
            
            CloseButton(action: closeStory)
                .padding(.trailing, Constants.closeButtonTrailingPadding)
                .padding(.top, Constants.closeButtonTopPadding)
            
            StoriesProgressBarView(
                storiesCount: stories.count,
                timerConfiguration: model.timerConfiguration,
                currentProgress: $model.currentProgress
            )
            .onChange(of: model.currentProgress) { newValue in
                withAnimation {
                    model.didChangeCurrentProgress(newProgress: newValue, currentStoryIndex: &currentStoryIndex)
                }
            }
        }
        .onAppear {
            withAnimation {
                model.saveStoryIndex(currentValue: currentStoryIndex, newValue: currentStoryIndex)
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

extension StoriesView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let closeButtonTrailingPadding: CGFloat = 12
        static let closeButtonTopPadding: CGFloat = 47
    }
    
    // MARK: - closeStory
    
    private func closeStory() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showStory = false
        }
    }
}

#Preview {
    let stories = SelectStationViewModel().stories
    StoriesView(
        stories: stories,
        showStory: .constant(false),
        currentStoryIndex: .constant(0)
    )
}
