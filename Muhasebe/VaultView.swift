import SwiftUI

struct VaultView: View {
    @EnvironmentObject var state: AppState
    @State private var activeFolderFilter: String = "All"
    @State private var selectedDocument: VaultDocument? = nil

    let folders = [
        (name: "Receipts", icon: "doc.text.fill", count: "12 files"),
        (name: "Invoices", icon: "doc.plaintext.fill", count: "8 files"),
        (name: "Tax Audits", icon: "shield.doc.fill", count: "3 files")
    ]

    var filteredDocuments: [VaultDocument] {
        if activeFolderFilter == "All" {
            return state.documents
        } else {
            return state.documents.filter { $0.category == activeFolderFilter }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("THE VAULT")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.primary)
                                    .tracking(1.5)

                                Text("Documents")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.black.opacity(0.85))
                            }
                            Spacer()

                            Button(action: {
                                withAnimation(Theme.fluidSpring) {

                                    state.startSimulatedUpload(
                                        title: "Stripe_Payout_Report_\(Int.random(in: 10...99)).pdf",
                                        category: activeFolderFilter == "All" ? "Receipts" : activeFolderFilter
                                    )
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.app.fill")
                                        .font(.system(size: 16))
                                    Text("Upload")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Theme.primary)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("FOLDERS")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                                .tracking(1.5)
                                .padding(.horizontal, 16)

                            HStack(spacing: 16) {
                                ForEach(folders, id: \.name) { folder in
                                    let isSelected = activeFolderFilter == folder.name

                                    Button(action: {
                                        withAnimation(Theme.fluidSpring) {
                                            if activeFolderFilter == folder.name {
                                                activeFolderFilter = "All"
                                            } else {
                                                activeFolderFilter = folder.name
                                            }
                                        }
                                    }) {
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack {
                                                if isSelected {
                                                    Image(systemName: folder.icon)
                                                        .font(.system(size: 24))
                                                        .foregroundColor(.white)
                                                } else {
                                                    Image(systemName: folder.icon)
                                                        .font(.system(size: 24))
                                                        .foregroundStyle(gradientForFolder(folder.name))
                                                }
                                                Spacer()

                                                if isSelected {
                                                    Circle()
                                                        .fill(Color.white)
                                                        .frame(width: 8, height: 8)
                                                }
                                            }

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(folder.name)
                                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                                    .foregroundColor(isSelected ? .white : Color.black.opacity(0.85))

                                                Text(folder.count)
                                                    .font(.system(size: 11, design: .rounded))
                                                    .foregroundColor(isSelected ? .white.opacity(0.8) : Theme.secondaryText)
                                            }
                                        }
                                        .padding(14)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(folderBackground(isSelected: isSelected, folderName: folder.name))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(isSelected ? Color.clear : Theme.border, lineWidth: 1)
                                        )
                                        .modifier(CardShadowModifier())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text(activeFolderFilter == "All" ? "ALL FILES" : activeFolderFilter.uppercased() + " FILES")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                                .tracking(1.5)
                                .padding(.horizontal, 16)

                            if filteredDocuments.isEmpty {
                                PremiumCard(padding: 24) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "folder.badge.minus")
                                            .font(.system(size: 32))
                                            .foregroundColor(Theme.secondaryText.opacity(0.5))
                                        Text("Folder is Empty")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(Theme.secondaryText)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 16)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredDocuments) { doc in
                                        DocumentRow(doc: doc)
                                            .onTapGesture {
                                                selectedDocument = doc
                                            }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 12)
                }

                if state.isUploadingDocument {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        OCRScanningView()
                            .transition(.scale)
                    }
                }
            }
            .hideNavigationBar()
            .sheet(item: $selectedDocument) { doc in
                DocumentViewerSheet(doc: doc)
            }
        }
    }

    private func folderBackground(isSelected: Bool, folderName: String) -> some View {
        Group {
            if isSelected {
                gradientForFolder(folderName)
            } else {
                LinearGradient(colors: [.white, .white], startPoint: .top, endPoint: .bottom)
            }
        }
    }

    private func gradientForFolder(_ folderName: String) -> LinearGradient {
        switch folderName.lowercased() {
        case "receipts":
            return Theme.primaryGradient
        case "invoices":
            return Theme.saasGradient
        case "tax audits":
            return Theme.opsGradient
        default:
            return Theme.primaryGradient
        }
    }
}

struct DocumentRow: View {
    let doc: VaultDocument

    var body: some View {
        PremiumCard(padding: 12) {
            HStack(spacing: 12) {

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.background)
                        .frame(width: 44, height: 52)

                    VStack(spacing: 2) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 18))
                            .foregroundColor(Theme.secondaryText)

                        Text("PDF")
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.primary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Theme.primary.opacity(0.12))
                            .cornerRadius(3)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(doc.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.85))
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(doc.category)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.secondaryText)

                        Circle()
                            .fill(Theme.border)
                            .frame(width: 3, height: 3)

                        Text(doc.size)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Theme.secondaryText)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.secondaryText.opacity(0.5))
                    .font(.system(size: 14))
            }
        }
    }
}

struct DocumentViewerSheet: View {
    @Environment(\.presentationMode) var presentationMode
    let doc: VaultDocument

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Capsule()
                    .fill(Theme.secondaryText.opacity(0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)

                Text(doc.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.85))
                    .lineLimit(1)
                    .padding(.horizontal, 20)

                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 8)

                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("INVOICE")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(Theme.primary)
                                    Text("Ref ID: \(doc.id.uuidString.prefix(8))")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(Theme.secondaryText)
                                }
                                Spacer()
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Theme.statusApproved)
                            }

                            Divider().background(Theme.border)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("COMPLIANCE VERIFIED")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.statusApproved)
                                    .tracking(1.0)

                                Text("This document is verified and archived under SEC Rule 17a-4 requirements for institutional accounting.")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(Theme.secondaryText)
                                    .lineSpacing(4)
                            }
                            .padding(12)
                            .background(Theme.statusApprovedBg)
                            .cornerRadius(10)

                            VStack(spacing: 12) {
                                InvoiceItemRow(name: "Professional Cloud Services", qty: "1", price: "$4,890.20")
                                InvoiceItemRow(name: "Data Warehouse Integration", qty: "2", price: "$2,200.00")
                                InvoiceItemRow(name: "Enterprise SLA Support", qty: "12", price: "$1,250.00")
                            }

                            Spacer()

                            Divider().background(Theme.border)

                            HStack {
                                Text("Archived On")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(Theme.secondaryText)
                                Spacer()
                                Text(doc.formattedDate)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.black.opacity(0.85))
                            }
                        }
                        .padding(24)
                    }
                }
                .padding(.horizontal, 20)
                .frame(maxHeight: 460)

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close Document")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.primary)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct InvoiceItemRow: View {
    let name: String
    let qty: String
    let price: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.8))
                Text("Quantity: \(qty)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(Theme.secondaryText)
            }
            Spacer()
            Text(price)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(Color.black.opacity(0.85))
        }
    }
}

struct OCRScanningView: View {
    @EnvironmentObject var state: AppState
    @State private var scanlineOffset: CGFloat = -50

    var body: some View {
        PremiumCard(padding: 24) {
            VStack(spacing: 16) {
                ZStack(alignment: .top) {
                    Image(systemName: "doc.viewfinder.fill")
                        .font(.system(size: 72))
                        .foregroundColor(Theme.primary.opacity(0.12))
                        .frame(width: 120, height: 120)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, Theme.primary, .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 100, height: 3)
                        .shadow(color: Theme.primary.opacity(0.8), radius: 4)
                        .offset(y: scanlineOffset)
                        .onAppear {

                            withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: true)) {
                                scanlineOffset = 50
                            }
                        }
                }

                Text("OCR Document Parsing")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.85))

                Text("Analyzing layout, extracting line items and metadata...")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                VStack(spacing: 6) {
                    ProgressView(value: state.uploadProgress)
                        .accentColor(Theme.primary)

                    Text("\(Int(state.uploadProgress * 100))%")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.primary)
                }
                .padding(.horizontal, 12)
            }
            .frame(width: 250)
        }
    }
}
