//
//  CollectionView.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 13/03/25.
//

import SwiftUI

struct CollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var roastCollection: RoastCollection
    @State private var showDeleteAlert = false
    @State private var roastToDelete: SavedRoast?
    
    private var gradientColors: LinearGradient {
        LinearGradient(colors: [.orange, .red],
                      startPoint: .leading,
                      endPoint: .trailing)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange.opacity(0.15), .red.opacity(0.15)],
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
              
                    Text("Burn Collection")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(gradientColors)
                        .padding()
                    
                if roastCollection.savedRoasts.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray.opacity(0.5))
                        
                        Text("No Saved Burns Yet")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Text("Start collecting your favorite roasts by tapping the save button!")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(roastCollection.savedRoasts) { roast in
                                RoastCard(roast: roast) {
                                    roastToDelete = roast
                                    showDeleteAlert = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .alert("Delete Roast", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let roast = roastToDelete {
                    roastCollection.deleteRoast(roast)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this roast?")
        }
    }
}

struct RoastCard: View {
    let roast: SavedRoast
    let onDelete: () -> Void
    
    @State private var isShareSheetPresented = false
    @State private var shareImage: UIImage?
    @Environment(\.colorScheme) private var colorScheme
    
    private var gradientColors: LinearGradient {
        LinearGradient(colors: [.orange, .red],
                      startPoint: .leading,
                      endPoint: .trailing)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func generateShareImage() -> UIImage {
        let shareCard = ShareCard(roastText: roast.roastText, titleText: roast.nameToRoast, forcedColorScheme: colorScheme)
        let renderer = ImageRenderer(content: shareCard)
        renderer.scale = 3.0
        renderer.isOpaque = true
        
        return renderer.uiImage ?? UIImage()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(roast.nameToRoast)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(gradientColors)
                
                Spacer()
                
                Button(action: {
                    shareImage = generateShareImage()
                    if shareImage != nil {
                        isShareSheetPresented = true
                    }
                }) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(gradientColors)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.red.opacity(0.7))
                }
            }
            
            Text(roast.roastText)
                .font(.body)
                .italic()
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            Text(dateFormatter.string(from: roast.dateCreated))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .sheet(isPresented: $isShareSheetPresented) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
    }
}





#Preview {
    CollectionView(roastCollection: RoastCollection())
}
