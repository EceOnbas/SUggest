import 'exchange_models.dart';
import 'geo.dart';

/// Placeholder data for Step 2. Firebase replaces it in Step 3.
abstract final class ExchangeMockData {
  static const destinations = <Destination>[
    // Erasmus, Europe
    Destination(school: 'TU Munich', city: 'Munich', lat: 48.15, lon: 11.57, students: 14, region: MapRegion.europe),
    Destination(school: 'Politecnico di Milano', city: 'Milan', lat: 45.48, lon: 9.23, students: 11, region: MapRegion.europe),
    Destination(school: 'University of Barcelona', city: 'Barcelona', lat: 41.39, lon: 2.17, students: 9, region: MapRegion.europe),
    Destination(school: 'TU Delft', city: 'Delft', lat: 52.00, lon: 4.37, students: 8, region: MapRegion.europe),
    Destination(school: 'TU Wien', city: 'Vienna', lat: 48.20, lon: 16.37, students: 8, region: MapRegion.europe),
    Destination(school: 'KTH Stockholm', city: 'Stockholm', lat: 59.35, lon: 18.07, students: 7, region: MapRegion.europe),
    Destination(school: 'University of Lisbon', city: 'Lisbon', lat: 38.75, lon: -9.15, students: 6, region: MapRegion.europe),
    Destination(school: 'Trinity College Dublin', city: 'Dublin', lat: 53.34, lon: -6.25, students: 6, region: MapRegion.europe),
    Destination(school: 'Charles University', city: 'Prague', lat: 50.08, lon: 14.42, students: 6, region: MapRegion.europe),
    Destination(school: 'University of Warsaw', city: 'Warsaw', lat: 52.24, lon: 21.02, students: 5, region: MapRegion.europe),
    Destination(school: 'Corvinus University', city: 'Budapest', lat: 47.49, lon: 19.05, students: 5, region: MapRegion.europe),
    Destination(school: 'Sapienza University', city: 'Rome', lat: 41.90, lon: 12.51, students: 5, region: MapRegion.europe),
    // Too few students: hidden by the privacy rule.
    Destination(school: 'University of Tartu', city: 'Tartu', lat: 58.38, lon: 26.72, students: 3, region: MapRegion.europe),
    // Exchange, world
    Destination(school: 'University of Melbourne', city: 'Melbourne', lat: -37.81, lon: 144.96, students: 7, region: MapRegion.world),
    Destination(school: 'NUS Singapore', city: 'Singapore', lat: 1.30, lon: 103.78, students: 6, region: MapRegion.world),
    Destination(school: 'Keio University', city: 'Tokyo', lat: 35.65, lon: 139.72, students: 6, region: MapRegion.world),
    Destination(school: 'University of Toronto', city: 'Toronto', lat: 43.66, lon: -79.40, students: 5, region: MapRegion.world),
    Destination(school: 'KAIST', city: 'Daejeon', lat: 36.37, lon: 127.36, students: 5, region: MapRegion.world),
    Destination(school: 'UC San Diego', city: 'San Diego', lat: 32.88, lon: -117.24, students: 5, region: MapRegion.world),
    Destination(school: 'University of São Paulo', city: 'Sao Paulo', lat: -23.56, lon: -46.73, students: 5, region: MapRegion.world),
  ];

  static const posts = <ExchangePost>[
    ExchangePost(id: 'p1', school: 'TU Munich', term: 'Fall 2026', text: 'The nomination deadline came earlier than I expected. Prepare your language certificate before the information session, because the host school checks it first.', topics: ['Application']),
    ExchangePost(id: 'p2', school: 'TU Munich', term: 'Spring 2026', text: 'Dorm applications opened four months before the term. Private rooms in the city cost about twice as much as the dorms.', topics: ['Housing', 'Costs']),
    ExchangePost(id: 'p3', school: 'TU Munich', term: 'Spring 2026', text: 'Course matching took two rounds. Ask your coordinator to confirm equivalents in writing before you leave.', topics: ['Courses']),
    ExchangePost(id: 'p4', school: 'Politecnico di Milano', term: 'Fall 2025', text: 'Classes are in English, but the lab sessions often switch to Italian. Ask the teaching assistant early.', topics: ['Courses', 'Life abroad']),
    ExchangePost(id: 'p5', school: 'University of Melbourne', term: 'Spring 2026', text: 'The student visa took six weeks. Apply as soon as the nomination email arrives and keep every receipt.', topics: ['Application', 'Costs']),
    ExchangePost(id: 'p6', school: 'University of Melbourne', term: 'Fall 2025', text: 'Most of my credits counted as free electives. Check the course list with your advisor before you pick modules.', topics: ['Courses']),
  ];
}
