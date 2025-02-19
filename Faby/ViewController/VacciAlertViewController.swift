//
//  VacciAlertViewController 2.swift
//  Faby
//
//  Created by Adarsh Mishra on 19/02/25.
//


import UIKit
import SwiftUI
import Combine

class VacciAlertViewController: UIViewController {
    // MARK: - Properties
    private let selectedDateSubject = PassthroughSubject<Date, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: VaccineViewModel
    
    // MARK: - Initialization
    init() {
        // Set baby's birth date to exactly 1 year ago
        let calendar = Calendar.current
        let babyBirthDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        self.viewModel = VaccineViewModel(babyBirthDate: babyBirthDate)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        navigationItem.hidesBackButton = true
        navigationItem.title = "VacciTime"
        view.backgroundColor = UIColor(hex: "#f2f2f7")
        
        let calendarContainer = UIHostingController(rootView:
            CalendarContainerView(
                selectedDate: selectedDateSubject.eraseToAnyPublisher(),
                onChevronTappedToNavigate: { [weak self] in
                    self?.navigateToVaccineReminderViewController()
                },
                onCardTapped: { [weak self] vaccine in
                    self?.handleVaccineScheduling(vaccine)
                },
                vaccineData: viewModel.getVaccineData()
            )
        )
        
        addChild(calendarContainer)
        calendarContainer.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarContainer.view)
        calendarContainer.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            calendarContainer.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarContainer.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarContainer.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarContainer.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    private func handleVaccineScheduling(_ vaccine: String) {
        if viewModel.scheduleVaccine(vaccine) {
            updateUIState()
            showAddVaccinationModal(for: vaccine)
        }
    }
    
    private func updateUIState() {
        let calendarContainer = children.first as? UIHostingController<CalendarContainerView>
        let updatedView = CalendarContainerView(
            selectedDate: selectedDateSubject.eraseToAnyPublisher(),
            onChevronTappedToNavigate: { [weak self] in
                self?.navigateToVaccineReminderViewController()
            },
            onCardTapped: { [weak self] vaccine in
                self?.handleVaccineScheduling(vaccine)
            },
            vaccineData: viewModel.getVaccineData()
        )
        calendarContainer?.rootView = updatedView
    }
    
    // MARK: - Navigation
    private func navigateToVaccineReminderViewController() {
        let reminderVC = VaccineReminderViewController()
        show(reminderVC, sender: self)
    }
    
    private func showAddVaccinationModal(for vaccine: String) {
        let hospitalVC = HospitalViewController()
        hospitalVC.vaccineName = vaccine
        hospitalVC.modalPresentationStyle = .pageSheet
        present(hospitalVC, animated: true)
    }
}