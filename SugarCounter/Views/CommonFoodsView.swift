import SwiftUI

struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let sugar: Double
    let serving: String
    let category: FoodCategory
}

enum FoodCategory: String, CaseIterable {
    case beverages = "Beverages"
    case breakfast = "Breakfast"
    case snacks = "Snacks"
    case desserts = "Desserts"
    case condiments = "Condiments"
    case dairy = "Dairy"
    case fastFood = "Fast Food"

    var icon: String {
        switch self {
        case .beverages: return "cup.and.saucer.fill"
        case .breakfast: return "sunrise.fill"
        case .snacks: return "carrot.fill"
        case .desserts: return "birthday.cake.fill"
        case .condiments: return "fork.knife"
        case .dairy: return "cup.and.saucer.fill"
        case .fastFood: return "bag.fill"
        }
    }

    var color: Color {
        switch self {
        case .beverages: return .blue
        case .breakfast: return .orange
        case .snacks: return .green
        case .desserts: return .pink
        case .condiments: return .yellow
        case .dairy: return .cyan
        case .fastFood: return .red
        }
    }
}

struct CommonFoodsView: View {
    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory?

    let foods: [FoodItem] = [
        // Beverages
        FoodItem(name: "Coca-Cola", sugar: 39, serving: "12 oz can", category: .beverages),
        FoodItem(name: "Pepsi", sugar: 41, serving: "12 oz can", category: .beverages),
        FoodItem(name: "Sprite", sugar: 38, serving: "12 oz can", category: .beverages),
        FoodItem(name: "Orange Juice", sugar: 21, serving: "8 oz glass", category: .beverages),
        FoodItem(name: "Apple Juice", sugar: 24, serving: "8 oz glass", category: .beverages),
        FoodItem(name: "Red Bull", sugar: 27, serving: "8.4 oz can", category: .beverages),
        FoodItem(name: "Monster Energy", sugar: 54, serving: "16 oz can", category: .beverages),
        FoodItem(name: "Gatorade", sugar: 21, serving: "12 oz bottle", category: .beverages),
        FoodItem(name: "Starbucks Frappuccino", sugar: 50, serving: "Grande", category: .beverages),
        FoodItem(name: "Starbucks Latte", sugar: 18, serving: "Grande", category: .beverages),
        FoodItem(name: "Sweet Tea", sugar: 33, serving: "16 oz", category: .beverages),
        FoodItem(name: "Hot Chocolate", sugar: 24, serving: "12 oz", category: .beverages),
        FoodItem(name: "Chocolate Milk", sugar: 24, serving: "8 oz", category: .beverages),
        FoodItem(name: "Vitamin Water", sugar: 27, serving: "20 oz bottle", category: .beverages),
        FoodItem(name: "Smoothie King", sugar: 55, serving: "Medium", category: .beverages),

        // Breakfast
        FoodItem(name: "Frosted Flakes", sugar: 12, serving: "1 cup", category: .breakfast),
        FoodItem(name: "Honey Nut Cheerios", sugar: 12, serving: "1 cup", category: .breakfast),
        FoodItem(name: "Fruit Loops", sugar: 12, serving: "1 cup", category: .breakfast),
        FoodItem(name: "Lucky Charms", sugar: 12, serving: "1 cup", category: .breakfast),
        FoodItem(name: "Cinnamon Toast Crunch", sugar: 12, serving: "1 cup", category: .breakfast),
        FoodItem(name: "Pop-Tart (2 pastries)", sugar: 32, serving: "2 pastries", category: .breakfast),
        FoodItem(name: "Maple Syrup", sugar: 52, serving: "1/4 cup", category: .breakfast),
        FoodItem(name: "Nutella", sugar: 21, serving: "2 tbsp", category: .breakfast),
        FoodItem(name: "Instant Oatmeal (flavored)", sugar: 12, serving: "1 packet", category: .breakfast),
        FoodItem(name: "Pancakes with Syrup", sugar: 28, serving: "3 pancakes", category: .breakfast),
        FoodItem(name: "Granola", sugar: 14, serving: "1/2 cup", category: .breakfast),
        FoodItem(name: "Breakfast Muffin", sugar: 24, serving: "1 muffin", category: .breakfast),

        // Snacks
        FoodItem(name: "Snickers Bar", sugar: 27, serving: "1 bar", category: .snacks),
        FoodItem(name: "M&Ms", sugar: 31, serving: "1.69 oz bag", category: .snacks),
        FoodItem(name: "Skittles", sugar: 47, serving: "2.17 oz bag", category: .snacks),
        FoodItem(name: "Nature Valley Bar", sugar: 12, serving: "2 bars", category: .snacks),
        FoodItem(name: "Clif Bar", sugar: 21, serving: "1 bar", category: .snacks),
        FoodItem(name: "KIND Bar", sugar: 5, serving: "1 bar", category: .snacks),
        FoodItem(name: "Dried Cranberries", sugar: 29, serving: "1/3 cup", category: .snacks),
        FoodItem(name: "Trail Mix", sugar: 16, serving: "1/4 cup", category: .snacks),
        FoodItem(name: "Fruit Snacks", sugar: 11, serving: "1 pouch", category: .snacks),
        FoodItem(name: "Graham Crackers", sugar: 8, serving: "2 sheets", category: .snacks),
        FoodItem(name: "Oreos (3 cookies)", sugar: 14, serving: "3 cookies", category: .snacks),

        // Desserts
        FoodItem(name: "Slice of Cake", sugar: 35, serving: "1 slice", category: .desserts),
        FoodItem(name: "Ice Cream", sugar: 21, serving: "1/2 cup", category: .desserts),
        FoodItem(name: "Cheesecake", sugar: 32, serving: "1 slice", category: .desserts),
        FoodItem(name: "Chocolate Chip Cookie", sugar: 10, serving: "1 large", category: .desserts),
        FoodItem(name: "Brownie", sugar: 18, serving: "1 piece", category: .desserts),
        FoodItem(name: "Donut (glazed)", sugar: 12, serving: "1 donut", category: .desserts),
        FoodItem(name: "Cinnamon Roll", sugar: 35, serving: "1 roll", category: .desserts),
        FoodItem(name: "Apple Pie", sugar: 30, serving: "1 slice", category: .desserts),
        FoodItem(name: "Milkshake", sugar: 54, serving: "Medium", category: .desserts),
        FoodItem(name: "Frozen Yogurt", sugar: 28, serving: "1/2 cup", category: .desserts),

        // Condiments
        FoodItem(name: "Ketchup", sugar: 4, serving: "1 tbsp", category: .condiments),
        FoodItem(name: "BBQ Sauce", sugar: 6, serving: "1 tbsp", category: .condiments),
        FoodItem(name: "Honey", sugar: 17, serving: "1 tbsp", category: .condiments),
        FoodItem(name: "Sweet Chili Sauce", sugar: 8, serving: "1 tbsp", category: .condiments),
        FoodItem(name: "Teriyaki Sauce", sugar: 7, serving: "1 tbsp", category: .condiments),
        FoodItem(name: "Ranch Dressing", sugar: 1, serving: "2 tbsp", category: .condiments),
        FoodItem(name: "Italian Dressing", sugar: 3, serving: "2 tbsp", category: .condiments),
        FoodItem(name: "Jam/Jelly", sugar: 10, serving: "1 tbsp", category: .condiments),
        FoodItem(name: "Peanut Butter", sugar: 3, serving: "2 tbsp", category: .condiments),
        FoodItem(name: "Hoisin Sauce", sugar: 7, serving: "1 tbsp", category: .condiments),

        // Dairy
        FoodItem(name: "Flavored Yogurt", sugar: 19, serving: "6 oz", category: .dairy),
        FoodItem(name: "Greek Yogurt (plain)", sugar: 4, serving: "6 oz", category: .dairy),
        FoodItem(name: "Greek Yogurt (flavored)", sugar: 12, serving: "6 oz", category: .dairy),
        FoodItem(name: "Ice Cream Sandwich", sugar: 16, serving: "1 sandwich", category: .dairy),
        FoodItem(name: "Pudding Cup", sugar: 18, serving: "1 cup", category: .dairy),
        FoodItem(name: "Whipped Cream", sugar: 1, serving: "2 tbsp", category: .dairy),
        FoodItem(name: "Coffee Creamer", sugar: 5, serving: "1 tbsp", category: .dairy),

        // Fast Food
        FoodItem(name: "McDonald's McFlurry", sugar: 64, serving: "Regular", category: .fastFood),
        FoodItem(name: "McDonald's Sweet Tea", sugar: 38, serving: "Large", category: .fastFood),
        FoodItem(name: "Wendy's Frosty", sugar: 47, serving: "Medium", category: .fastFood),
        FoodItem(name: "Subway Cookie", sugar: 18, serving: "1 cookie", category: .fastFood),
        FoodItem(name: "Dunkin' Donut", sugar: 14, serving: "1 glazed", category: .fastFood),
        FoodItem(name: "Starbucks Cake Pop", sugar: 18, serving: "1 pop", category: .fastFood),
        FoodItem(name: "Chick-fil-A Lemonade", sugar: 58, serving: "Medium", category: .fastFood),
        FoodItem(name: "Dairy Queen Blizzard", sugar: 68, serving: "Medium", category: .fastFood),
    ]

    private var filteredFoods: [FoodItem] {
        var result = foods
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return result.sorted { $0.sugar > $1.sugar }
    }

    private var groupedFoods: [(FoodCategory, [FoodItem])] {
        let grouped = Dictionary(grouping: filteredFoods) { $0.category }
        return FoodCategory.allCases.compactMap { category in
            if let foods = grouped[category], !foods.isEmpty {
                return (category, foods)
            }
            return nil
        }
    }

    var body: some View {
        List {
            if selectedCategory == nil {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(FoodCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    onTap: {
                                        withAnimation {
                                            if selectedCategory == category {
                                                selectedCategory = nil
                                            } else {
                                                selectedCategory = category
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            } else {
                Section {
                    Button {
                        withAnimation {
                            selectedCategory = nil
                        }
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Clear Filter: \(selectedCategory!.rawValue)")
                        }
                        .foregroundColor(.accentColor)
                    }
                }
            }

            ForEach(groupedFoods, id: \.0) { category, foods in
                Section(header: CategoryHeader(category: category)) {
                    ForEach(foods) { food in
                        FoodRow(food: food)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search foods...")
        .navigationTitle("Common Foods")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CategoryHeader: View {
    let category: FoodCategory

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: category.icon)
                .foregroundColor(category.color)
            Text(category.rawValue)
        }
    }
}

struct CategoryChip: View {
    let category: FoodCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct FoodRow: View {
    let food: FoodItem

    private var sugarColor: Color {
        if food.sugar <= 10 {
            return .green
        } else if food.sugar <= 25 {
            return .yellow
        } else {
            return .red
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.headline)
                Text(food.serving)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(Int(food.sugar))g")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(sugarColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(sugarColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        CommonFoodsView()
    }
}
