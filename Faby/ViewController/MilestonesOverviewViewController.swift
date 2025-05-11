import UIKit

protocol MilestonesOverviewDelegate: AnyObject {
    func milestonesOverviewDidUpdate()
}

class MilestonesOverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MilestonesOverviewDelegate {
    func milestonesOverviewDidUpdate() {
        reloadMilestones()
    }
    
    var baby: Baby?
    var dataController: DataController {
        return DataController.shared
    }
    weak var delegate: MilestonesOverviewDelegate?
    
    private let segmentedControl = UISegmentedControl(items: ["Cognitive", "Language", "Physical", "Social"])
    private let donutChartView = UIView()
    private let tableView = UITableView()
    var categoryName = ["Cognitive", "Language", "Physical", "Social"]
    private var selectedCategory = 0
    private var milestones: [GrowthMilestone] = []
    private var totalMilestones = 0
    private var achievedMilestones = 0
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No milestone added yet"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.isHidden = false
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baby = dataController.baby
        view.backgroundColor = .systemGray6
        setupNavigationBar()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(handleMilestoneUpdate), name: .milestonesAchievedUpdated, object: nil)
            
        updateCategory(index: selectedCategory)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMilestones()
    }
    
    func reloadMilestones() {
        let selectedCategoryName = categoryName[selectedCategory].lowercased()
        milestones = dataController.milestones.filter {
            $0.category.rawValue == selectedCategoryName && $0.isAchieved
        }
        totalMilestones = dataController.milestones.filter {
            $0.category.rawValue == selectedCategoryName
        }.count
        achievedMilestones = milestones.count

        updateDonutChart()
        tableView.reloadData()
        emptyLabel.isHidden = !milestones.isEmpty
    }

    
    @objc private func handleMilestoneUpdate() {
        reloadMilestones()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        
        title = "Milestones Overview"
    }
    
    private func setupUI() {
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        donutChartView.backgroundColor = .clear
        view.addSubview(donutChartView)
        donutChartView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGray6
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MilestoneTableViewCell.self, forCellReuseIdentifier: "MilestoneCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            donutChartView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            donutChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            donutChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            donutChartView.heightAnchor.constraint(equalTo: donutChartView.widthAnchor, multiplier: 0.7),
            
            tableView.topAnchor.constraint(equalTo: donutChartView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 65),
        ])
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let newSelectedCategory = sender.selectedSegmentIndex
        if newSelectedCategory != selectedCategory {
            selectedCategory = newSelectedCategory
            updateCategory(index: selectedCategory)
        }
    }

    private func updateCategory(index: Int) {
        selectedCategory = index
        reloadMilestones()
    }
    
    private func updateDonutChart() {
        let percentage = totalMilestones > 0 ? CGFloat(achievedMilestones) / CGFloat(totalMilestones) : 0.0
        drawDonutChart(percentage: percentage)
    }
    
    private func drawDonutChart(percentage: CGFloat) {
        donutChartView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let radius: CGFloat = donutChartView.frame.width / 4
        let lineWidth: CGFloat = 18.0
        
        let backgroundLayer = CAShapeLayer()
        
        let center = CGPoint(x: donutChartView.frame.width / 2, y: donutChartView.frame.height / 2)
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise:true)
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.fillColor = UIColor.clear.cgColor
        donutChartView.layer.addSublayer(backgroundLayer)
        
        let achievedLayer = CAShapeLayer()
        achievedLayer.path = circularPath.cgPath
        achievedLayer.strokeColor = UIColor.green.cgColor
        achievedLayer.lineWidth = lineWidth
        achievedLayer.fillColor = UIColor.clear.cgColor
        achievedLayer.strokeEnd = percentage
        donutChartView.layer.addSublayer(achievedLayer)
    
        let progressLabel = UILabel()
        progressLabel.text = "Progress"
        progressLabel.font = UIFont.boldSystemFont(ofSize: 24)
        progressLabel.textAlignment = .center
        progressLabel.textColor = .black
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        donutChartView.addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: donutChartView.centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: donutChartView.centerYAnchor)
        ])
    }
    
    private func fetchMilestones(for categoryIndex: Int) -> [GrowthMilestone] {
        let category: GrowthCategory = {
            switch categoryIndex {
            case 0: return .cognitive
            case 1: return .language
            case 2: return .physical
            case 3: return .social
            default: return .cognitive
            }
        }()
        
        let milestonesInCategory = dataController.milestones.filter { $0.category == category }
        
        return milestonesInCategory.map { milestone in
            var updated = milestone
            if updated.isAchieved, let date = updated.achievedDate {
                updated.description += "\nAchieved on \(date.formatted())"
            }
            return updated
        }
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return milestones.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let label = UILabel()
        label.text = "Recently Achieved Milestones"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
            
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
            
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MilestoneCell", for: indexPath) as! MilestoneTableViewCell
        let milestone = milestones[indexPath.row]
        cell.configure(with: milestone, achievedDate: milestone.achievedDate)
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDonutChart()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
