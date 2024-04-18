//
//  SettingView.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 12/14/23.
//

import SwiftUI
import StoreKit

struct SettingView: View {
    @AppStorage("darkModeOn") private var darkModeOn = false
    
    private let lineSpacing: CGFloat = 5
    
    @State private var showPopup: Bool = false
    @State private var popupContent: PopupContent = .showReview
    
    @Environment(\.requestReview) private var requestReview
        
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        NavigationLink {
                            AboutView
                        } label: {
                            Image(systemName: "a.square")
                            Text("About InboxZ")
                        }
                        
                        Toggle(isOn: $darkModeOn, label: {
                            HStack {
                                Image(systemName: "moon.dust")
                                Text("Dark Mode")
                            }
                        })
                        
                        Button(action: {
                            showPopup = true
                            popupContent = .showContact
                        }, label: {
                            Image(systemName: "exclamationmark.bubble")
                            Text("Contact Us")
                        })
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            //showPopup = true
                            //popupContent = .showReview
                            //SKStoreReviewController.requestReview(in: <#T##UIWindowScene#>)
                            DispatchQueue.main.async {
                                requestReview()
                            }
                        }, label: {
                            Image(systemName: "hand.thumbsup")
                            Text("Like The App? Write Us A Review")
                        })
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.inset)
                .navigationTitle("Setting")
                .navigationBarTitleDisplayMode(.inline)
                
                if showPopup {
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showPopup = false
                        }
                    
                    VStack {
                        switch popupContent {
                        case .showReview:
                            Text("Show Review")
                        case .showContact:
                            ContactView()
                        }
                    }
                    .foregroundStyle(darkModeOn ? Color.white : Color.black)
                    .frame(width: 300, height: 500)
                    .background(darkModeOn ? Color.black : Color.white)
                    .border(darkModeOn ? Color.white : Color.black, width: 1)
                    .transition(AnyTransition.scale.animation(.easeInOut))
                    .zIndex(2)
                }
            } // end ZStack
        } // end NavigationStack
    }
    
    // MARK: Nested Struct
    private var AboutView: some View {
        ScrollView {
            Text("What is InboxZ?")
                .font(.title)
                .padding(.top, 30)
            /*
             VStack(alignment: .leading) {
             Divider()
             .padding(.bottom)
             Text("InboxZ is a productivity app that aim to combat procrastination and preserve mental energy by help users *start* their task. Procrastination is a universal challenge: we all grapple with it, even when we loathe its effects. Personally, I've explored numerous productivity tools available on the App Store—from time planners and habit trackers to to-do lists, daily reminders, meditation apps, Pomodoro techniques, and distraction blockers—yet found minimal success. Then I found this [post](https://www.lesswrong.com/posts/9o3QBg2xJXcRCxGjS/working-hurts-less-than-procrastinating-we-fear-the-twinge) written by Eliezer Yudkowsky. The post captures the essence of procrastination: the challenge lies not in completing tasks, but in initiating them. With this insight as inspiration, the primary goal of InboxZ is to empower you to take that crucial first step.")
             .lineSpacing(lineSpacing)
             Divider()
             Text("What InboxZ mean?")
             .font(.title3)
             .fontWeight(.light)
             .padding(.vertical)
             Text("Z here stand for Zero. Inbox is the number of tasks you need to do today, once you complete all those tasks, you achieve InboxZero.")
             .lineSpacing(lineSpacing)
             Divider()
             Text("How to use InboxZ?")
             .font(.title3)
             .fontWeight(.light)
             .padding(.vertical)
             Text("User create tasks. Every task has 3 states, \(Text("**Active**").foregroundStyle(.green)), \(Text("**In Progress**").foregroundStyle(.orange)), and \(Text("**Completed**").foregroundStyle(.blue)). Let say you need to make an appointment with your dentist. If you can do the task now, then the task is in Active state. If the task is not complete but you can't do anything about it, like waiting for your dentist's confirmation for example, then the task is In-Progress state, put a task in In-Progress state help you focus on other Active tasks. If the task is completed you can register the task.")
             .lineSpacing(lineSpacing)
             
             Text("What register a completed task mean?")
             .font(.title3)
             .fontWeight(.light)
             .padding(.vertical)
             Text("Register a completed task means count the task's completion toward a goal/benefit.")
             .lineSpacing(lineSpacing)
             Text("What is goal? I thought this is not a goal tracking app?")
             .font(.title3)
             .fontWeight(.light)
             .padding(.vertical)
             Text("You are correct, InboxZ is NOT a goal tracking app. Goal should be treated as a benefit to complete the task. We human have delay accounting bias which make the immediate pain of starting the task out weight the reward of completing the task in the future. Having goal/benefit associate with each task make the task easier to start. That said, if you want to use InboxZ as a goal tracking app, that work too. I want this app to be simple and versatile for all its users.")
             .lineSpacing(lineSpacing)
             .padding(.bottom)
             }*/
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
    }
    
    enum PopupContent {
        case showReview, showContact
    }
    
}

struct ContactView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "person.2")
                .font(.system(size: 100))
            Spacer()
            Text("If you have any bug reports, feature requests, or questions about InboxZ, please contact us using the email below with **inboxz** as **Subject**. We appreciate and value all feedbacks of our users.")
            Spacer()
            Text("Contacts us: ")
            Spacer()
            Text("inboxzero3@gmail.com")
            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    SettingView()
}
