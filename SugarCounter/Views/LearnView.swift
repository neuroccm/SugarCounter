import SwiftUI

struct LearnView: View {
    @State private var selectedSection: LearnSection = .overview
    @State private var showingAbout = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        SugarOverviewView()
                    } label: {
                        LearnRowView(
                            icon: "info.circle.fill",
                            iconColor: .blue,
                            title: "Understanding Sugar",
                            subtitle: "What is refined sugar and why track it?"
                        )
                    }

                    NavigationLink {
                        CommonFoodsView()
                    } label: {
                        LearnRowView(
                            icon: "fork.knife",
                            iconColor: .orange,
                            title: "Sugar in Common Foods",
                            subtitle: "Quick reference guide"
                        )
                    }

                    NavigationLink {
                        HiddenSugarsView()
                    } label: {
                        LearnRowView(
                            icon: "eye.slash.fill",
                            iconColor: .purple,
                            title: "Hidden Sugars",
                            subtitle: "Surprising sources of sugar"
                        )
                    }

                    NavigationLink {
                        HealthTipsView()
                    } label: {
                        LearnRowView(
                            icon: "heart.fill",
                            iconColor: .red,
                            title: "Health Tips",
                            subtitle: "Strategies to reduce sugar intake"
                        )
                    }
                } header: {
                    Text("Learn About Sugar")
                }

                Section {
                    NavigationLink {
                        GuidelinesView()
                    } label: {
                        LearnRowView(
                            icon: "doc.text.fill",
                            iconColor: .green,
                            title: "Official Guidelines",
                            subtitle: "WHO & AHA recommendations"
                        )
                    }
                } header: {
                    Text("References")
                }
            }
            .navigationTitle("Learn")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

enum LearnSection: String, CaseIterable {
    case overview = "Overview"
    case foods = "Foods"
    case tips = "Tips"
}

struct LearnRowView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Sugar Overview

struct SugarOverviewView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                InfoCard(
                    title: "What is Refined Sugar?",
                    content: "Refined sugar (also called added sugar) is sugar that has been processed and added to foods. This includes white sugar, brown sugar, high-fructose corn syrup, and other sweeteners. It's different from natural sugars found in whole fruits and vegetables.",
                    icon: "cube.fill",
                    color: .blue
                )

                InfoCard(
                    title: "Why Track It?",
                    content: "Excessive sugar consumption is linked to obesity, type 2 diabetes, heart disease, and tooth decay. Most people consume far more sugar than recommended without realizing it. Tracking helps build awareness of your actual intake.",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )

                InfoCard(
                    title: "Natural vs. Added Sugar",
                    content: "Natural sugars in whole fruits come with fiber, vitamins, and minerals that slow absorption. Added sugars provide empty calories with no nutritional benefit. This app focuses on tracking added/refined sugars.",
                    icon: "leaf.fill",
                    color: .green
                )

                InfoCard(
                    title: "Reading Labels",
                    content: "Check the 'Added Sugars' line on nutrition labels. Sugar has many names: sucrose, glucose, fructose, maltose, dextrose, corn syrup, and anything ending in '-ose' is likely a sugar.",
                    icon: "doc.text.magnifyingglass",
                    color: .purple
                )
            }
            .padding()
        }
        .navigationTitle("Understanding Sugar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Hidden Sugars

struct HiddenSugarsView: View {
    let hiddenSugarFoods: [(String, String, String)] = [
        ("Pasta Sauce", "6-12g per serving", "jarred sauces often contain added sugar"),
        ("Bread", "2-4g per slice", "even 'healthy' whole wheat bread"),
        ("Yogurt", "12-25g per cup", "flavored yogurts are sugar bombs"),
        ("Salad Dressing", "4-8g per serving", "especially low-fat varieties"),
        ("Granola Bars", "8-15g per bar", "marketed as healthy but sugar-laden"),
        ("Protein Bars", "10-20g per bar", "check labels carefully"),
        ("Smoothies", "30-60g per drink", "store-bought ones add extra sugar"),
        ("Ketchup", "4g per tablespoon", "1 tbsp = 1 tsp of sugar"),
        ("BBQ Sauce", "6-8g per tablespoon", "one of the highest per serving"),
        ("Instant Oatmeal", "10-15g per packet", "flavored varieties"),
        ("Sports Drinks", "21-35g per bottle", "designed for athletes, not daily use"),
        ("Canned Soup", "6-15g per can", "especially tomato-based"),
    ]

    var body: some View {
        List {
            Section {
                Text("Many foods marketed as healthy contain surprising amounts of added sugar. Always check nutrition labels!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            }

            Section("Watch Out For") {
                ForEach(hiddenSugarFoods, id: \.0) { food in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(food.0)
                                .font(.headline)
                            Spacer()
                            Text(food.1)
                                .font(.subheadline)
                                .foregroundColor(.orange)
                                .fontWeight(.medium)
                        }
                        Text(food.2)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Hidden Sugars")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Health Tips

struct HealthTipsView: View {
    let tips: [(String, String, String)] = [
        ("drink.fill", "Drink Water", "Replace sodas and juices with water. Add lemon or cucumber for flavor without sugar."),
        ("cart.fill", "Shop the Perimeter", "Fresh foods around store edges have less added sugar than processed foods in center aisles."),
        ("book.fill", "Read Labels", "Check 'Added Sugars' on nutrition facts. Aim for products with 0g or minimal added sugar."),
        ("moon.fill", "Sleep Well", "Poor sleep increases sugar cravings. Aim for 7-9 hours per night."),
        ("figure.walk", "Stay Active", "Exercise helps regulate blood sugar and reduces cravings."),
        ("clock.fill", "Eat Regularly", "Skipping meals leads to blood sugar drops and increased cravings."),
        ("apple.logo", "Choose Whole Fruits", "Satisfy sweet cravings with whole fruits instead of desserts."),
        ("takeoutbag.and.cup.and.straw.fill", "Cook at Home", "Restaurant and packaged foods often contain hidden sugars."),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(tips, id: \.1) { tip in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: tip.0)
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(tip.1)
                                .font(.headline)
                            Text(tip.2)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Health Tips")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Guidelines

struct GuidelinesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                InfoCard(
                    title: "World Health Organization (WHO)",
                    content: "WHO recommends adults and children reduce their daily intake of free sugars to less than 10% of total energy intake. A further reduction to below 5% (approximately 25g or 6 teaspoons per day) would provide additional health benefits.",
                    icon: "globe",
                    color: .blue
                )

                InfoCard(
                    title: "American Heart Association (AHA)",
                    content: "The AHA recommends limiting added sugars to no more than 6 teaspoons (25 grams) per day for women and 9 teaspoons (36 grams) per day for men. Children should have less than 6 teaspoons per day.",
                    icon: "heart.fill",
                    color: .red
                )

                InfoCard(
                    title: "Current Reality",
                    content: "The average American consumes about 17 teaspoons (71 grams) of added sugar daily - nearly 3 times the recommended amount for women and almost double for men.",
                    icon: "chart.bar.fill",
                    color: .orange
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Limits Summary")
                        .font(.headline)

                    HStack(spacing: 16) {
                        GuidelineCard(label: "Women", amount: "25g", icon: "person.fill")
                        GuidelineCard(label: "Men", amount: "36g", icon: "person.fill")
                        GuidelineCard(label: "Children", amount: "<25g", icon: "figure.and.child.holdinghands")
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle("Official Guidelines")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GuidelineCard: View {
    let label: String
    let amount: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)

            Text(amount)
                .font(.title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct InfoCard: View {
    let title: String
    let content: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.headline)
            }

            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    LearnView()
}
