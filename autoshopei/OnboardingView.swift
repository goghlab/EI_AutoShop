import SwiftUI

struct OnboardingView: View {
    @State private var isShowingSignupView = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image("bg1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Image("icon2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 250)
                        .padding(.bottom, -10)
                    
                    NavigationLink(
                        destination: Signup(),
                        isActive: $isShowingSignupView,
                        label: {
                            EmptyView()
                        }
                    )
                }
                .padding()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isShowingSignupView = true
                    }
                }
            }
        }
    }
}
