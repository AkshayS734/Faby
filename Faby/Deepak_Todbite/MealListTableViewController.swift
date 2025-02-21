import UIKit

class MealListViewController: UITableViewController {
    let meals: [FeedingMeal] = [
        FeedingMeal(name: "Dalia", description: "High in fiber, calcium, and protein.", image: "Dalia", category: .EarlyBite),
        FeedingMeal(name: "Poha with Vegetables", description: "Light, iron-rich, and full of vitamins.", image: "Poha with Vegetables", category: .EarlyBite),
        FeedingMeal(name: "Mashed Banana with Milk", description: "Rich in potassium and calcium.", image: "Mashed Banana with Milk", category: .EarlyBite),
        FeedingMeal(name: "Soft Aloo Paratha with Ghee", description: "Rich in potassium and calcium.", image: "Soft Aloo Paratha with Ghee", category: .EarlyBite),
        FeedingMeal(name: "Boiled Green Peas and Potatoes", description: "Rich in protein, iron, and healthy fats.", image: "Boiled Green Peas and Potatoes", category: .NourishBite),
        FeedingMeal(name: "Moong Dal Khichdi with Vegetables", description: "Packed with protein, fiber.", image: "Moong Dal Khichdi with Vegetables", category: .NourishBite),
        FeedingMeal(name: "Spinach Dal with Rice", description: "Packed with protein, fiber.", image: "Spinach Dal with Rice", category: .NourishBite),
        FeedingMeal(name: "Mashed Lentils with Ghee Rice", description: "Packed with protein, fiber.", image: "Mashed Lentils with Ghee Rice", category: .NourishBite),
        FeedingMeal(name: "Dal Chawal with Ghee", description: "Provides protein, fiber, and fats.", image: "Dal Chawal with Ghee", category: .MidDayBite),
        FeedingMeal(name: "Palak Paneer with Rice", description: "High in iron, calcium, and protein.", image: "Palak Paneer with Rice", category: .MidDayBite),
        FeedingMeal(name: "Vegetable Pulao", description: "High in iron, calcium, and protein.", image: "Vegetable Pulao", category: .MidDayBite),
        FeedingMeal(name: "Aloo Gobhi with Roti", description: "High in iron, calcium, and protein.", image: "Aloo Gobhi with Roti", category: .MidDayBite),
        FeedingMeal(name: "Boiled Sweet Corn", description: "Rich in fiber, vitamins, and natural energy.", image: "Boiled Sweet Corn", category: .SnackBite),
        FeedingMeal(name: "Mashed Seasonal Fruits", description: "High in protein and easy to digest.", image: "Mashed Seasonal Fruits", category: .SnackBite),
        FeedingMeal(name: "Dhokla", description: "High in protein and easy to digest.", image: "Dhokla", category: .SnackBite),
        FeedingMeal(name: "Milk with Dry Fruits", description: "Rich in protein, fiber, and essential nutrients.", image: "Milk with Dry Fruits", category: .NightBite),
        FeedingMeal(name: "Palak Paneer with Rice", description: "Loaded with iron, calcium, and vitamins.", image: "Palak Paneer with Rice", category: .NightBite),
        FeedingMeal(name: "Gobhi Aloo With Roti", description: "Loaded with iron, calcium, and vitamins.", image: "Gobhi Aloo With Roti", category: .NightBite)
    ]

    
    var onMealSelected: ((FeedingMeal) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select a Meal"
        tableView.register(MealTableViewCell.self, forCellReuseIdentifier: "MealCell")
        tableView.rowHeight = 80 // ✅ Increase row height for better spacing
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as? MealTableViewCell else {
            return UITableViewCell()
        }
        let meal = meals[indexPath.row]
        cell.configure(with: meal)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMeal = meals[indexPath.row]
        onMealSelected?(selectedMeal)
        navigationController?.popViewController(animated: true)
    }
}



