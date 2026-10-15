import 'package:flutter/material.dart';
import '../../../data/model/resident_model.dart';
import '../../../data/repo/resident_repository.dart';

class CuDanScreen extends StatefulWidget {
  const CuDanScreen({super.key});

  @override
  State<CuDanScreen> createState() => _CuDanScreenState();
}

class _CuDanScreenState extends State<CuDanScreen> {
  final ResidentRepository _repository = ResidentRepository();
  late Future<List<ResidentModel>> _residentsFuture;

  @override
  void initState() {
    super.initState();
    _residentsFuture = _repository.getResidents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("data"),
    );
  }
}
