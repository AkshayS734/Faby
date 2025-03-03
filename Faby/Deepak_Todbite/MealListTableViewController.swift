import UIKit

class MealListViewController: UITableViewController {
    
    let meals: [FeedingMeal] = [
        FeedingMeal(name: "Dalia", description: "High in fiber, calcium, and protein.", image: "Dalia", category: .EarlyBite, region: .north, ageGroup: .months12to18),
        FeedingMeal(name: "Poha with Vegetables", description: "Light, iron-rich, and full of vitamins.", image: "Poha with Vegetables", category: .EarlyBite, region: .west, ageGroup: .months12to18),
        FeedingMeal(name: "Mashed Banana with Milk", description: "Rich in potassium and calcium.", image: "Mashed Banana with Milk", category: .EarlyBite, region: .east, ageGroup: .months12to18),
        FeedingMeal(name: "Soft Aloo Paratha with Ghee", description: "Rich in potassium and calcium.", image: "Soft Aloo Paratha with Ghee", category: .EarlyBite, region: .north, ageGroup: .months18to24),

        FeedingMeal(name: "Boiled Green Peas and Potatoes", description: "Rich in protein, iron, and healthy fats.", image: "Boiled Green Peas and Potatoes", category: .NourishBite, region: .south, ageGroup: .months12to18),
        FeedingMeal(name: "Moong Dal Khichdi with Vegetables", description: "Packed with protein, fiber.", image: "Moong Dal Khichdi with Vegetables", category: .NourishBite, region: .east, ageGroup: .months18to24),
        FeedingMeal(name: "Spinach Dal with Rice", description: "Packed with protein, fiber.", image: "Spinach Dal with Rice", category: .NourishBite, region: .west, ageGroup: .months12to18),
        FeedingMeal(name: "Mashed Lentils with Ghee Rice", description: "Packed with protein, fiber.", image: "Mashed Lentils with Ghee Rice", category: .NourishBite, region: .north, ageGroup: .months24to30),

        FeedingMeal(name: "Dal Chawal with Ghee", description: "Provides protein, fiber, and fats.", image: "Dal Chawal with Ghee", category: .MidDayBite, region: .south, ageGroup: .months12to18),
        FeedingMeal(name: "Palak Paneer with Rice", description: "High in iron, calcium, and protein.", image: "Palak Paneer with Rice", category: .MidDayBite, region: .north, ageGroup: .months18to24),
        FeedingMeal(name: "Vegetable Pulao", description: "High in iron, calcium, and protein.", image: "Vegetable Pulao", category: .MidDayBite, region: .east, ageGroup: .months24to30),
        FeedingMeal(name: "Aloo Gobhi with Roti", description: "High in iron, calcium, and protein.", image: "Aloo Gobhi with Roti", category: .MidDayBite, region: .west, ageGroup: .months30to36),

        FeedingMeal(name: "Boiled Sweet Corn", description: "Rich in fiber, vitamins, and natural energy.", image: "Boiled Sweet Corn", category: .SnackBite, region: .south, ageGroup: .months12to18),
        FeedingMeal(name: "Mashed Seasonal Fruits", description: "High in protein and easy to digest.", image: "Mashed Seasonal Fruits", category: .SnackBite, region: .east, ageGroup: .months18to24),
        FeedingMeal(name: "Dhokla", description: "High in protein and easy to digest.", image: "Dhokla", category: .SnackBite, region: .west, ageGroup: .months12to18),

        FeedingMeal(name: "Milk with Dry Fruits", description: "Rich in protein, fiber, and essential nutrients.", image: "Milk with Dry Fruits", category: .NightBite, region: .north, ageGroup: .months24to30),
        FeedingMeal(name: "Palak Paneer with Rice", description: "Loaded with iron, calcium, and vitamins.", image: "Palak Paneer with Rice", category: .NightBite, region: .south, ageGroup: .months12to18),
        FeedingMeal(name: "Gobhi Aloo With Roti", description: "Loaded with iron, calcium, and vitamins.", image: "Gobhi Aloo With Roti", category: .NightBite, region: .west, ageGroup: .months18to24)
    ]


    
    var onMealSelected: ((FeedingMeal) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select a Meal"
        tableView.register(MealTableViewCell.self, forCellReuseIdentifier: "MealCell")
        tableView.rowHeight = 80 
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




