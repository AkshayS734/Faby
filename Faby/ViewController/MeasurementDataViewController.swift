import UIKit

class MeasurementDataViewController: UIViewController {
    var baby: Baby?
    var measurementType: String
    var onDataChanged: (() -> Void)?
    
    private var tableView: UITableView!
    private var noDataLabel: UILabel!
    private var tableViewHeightConstraint: NSLayoutConstraint?

    init(measurementType: String, baby: Baby?, onDataChanged: (() -> Void)?) {
        self.measurementType = measurementType
        self.baby = baby
        self.onDataChanged = onDataChanged
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = "\(measurementType) Data"

        setupNoDataLabel()
        setupTableView()
        setupNavigationBar()
        updateUI()
    }

    private func setupNoDataLabel() {
        noDataLabel = UILabel()
        noDataLabel.text = "No data"
        noDataLabel.textColor = .darkGray
        noDataLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        noDataLabel.textAlignment = .center
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)

        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 12
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView()
        tableView.register(MeasurementDataTableViewCell.self, forCellReuseIdentifier: "DataCell")
        tableView.allowsSelectionDuringEditing = true
        tableView.sectionHeaderHeight = 0
        tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        tableView.isScrollEnabled = false

        view.addSubview(tableView)

        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewHeightConstraint!
        ])
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(toggleEditMode)
        )
    }

    @objc private func toggleEditMode() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
    }

    private func updateUI() {
        let dataCount = dataCountForSelectedMeasurementType()
        
        if dataCount == 0 {
            noDataLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noDataLabel.isHidden = true
            tableView.isHidden = false
            tableViewHeightConstraint?.constant = CGFloat(dataCount) * 50
        }
    }

    private func unitForMeasurementType() -> String {
        switch measurementType {
        case "Height", "Head Circumference": return "cm"
        case "Weight": return "kg"
        default: return ""
        }
    }

    private func dataCountForSelectedMeasurementType() -> Int {
        switch measurementType {
        case "Height": return baby?.height.count ?? 0
        case "Weight": return baby?.weight.count ?? 0
        case "Head Circumference": return baby?.headCircumference.count ?? 0
        default: return 0
        }
    }

    private func deleteEntry(at index: Int) {
        switch measurementType {
        case "Height":
            let values = Array(baby?.height.keys.sorted() ?? [])
            baby?.removeHeight(values[index])
        case "Weight":
            let values = Array(baby?.weight.keys.sorted() ?? [])
            baby?.removeWeight(values[index])
        case "Head Circumference":
            let values = Array(baby?.headCircumference.keys.sorted() ?? [])
            baby?.removeHeadCircumference(values[index])
        default:
            break
        }
        onDataChanged?()
        tableView.reloadData()
        updateUI()
    }
}

extension MeasurementDataViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataCountForSelectedMeasurementType()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? MeasurementDataTableViewCell else {
            return UITableViewCell()
        }

        let unit = unitForMeasurementType()
        let values: [(Double, Date)] = {
            switch measurementType {
            case "Height":
                return baby?.height.map { ($0.key, $0.value) } ?? []
            case "Weight":
                return baby?.weight.map { ($0.key, $0.value) } ?? []
            case "Head Circumference":
                return baby?.headCircumference.map { ($0.key, $0.value) } ?? []
            default:
                return []
            }
        }()
        
        if indexPath.row < values.count {
            let (value, date) = values.sorted(by: { $0.1 > $1.1 })[indexPath.row]
            cell.configure(value: value, unit: unit, date: date)
        }
        if indexPath.row == values.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            cell.layoutMargins = .zero
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteEntry(at: indexPath.row)
        }
    }
}
