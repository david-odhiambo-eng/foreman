import 'package:flutter/material.dart';
import 'package:foreman/viewModel/data_structure.dart';
import 'package:foreman/views/home/bottom_navigation.dart';
import 'package:foreman/views/home/textStyle.dart';
import 'package:foreman/views/jobs/created_jobs.dart';
import 'package:foreman/views/jobs/details_page.dart';

class PostJob extends StatefulWidget {
  const PostJob({super.key});

  @override
  State<PostJob> createState() => _PostJobState();
}

class _PostJobState extends State<PostJob> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a worker category\nor create your own',
                style: reusableStyle1().copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Details()));
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Add Worker Group',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _showWorkerList()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 2,),
    );
  }

  Widget _showWorkerList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: DataStructure.jobs.length,
      itemBuilder: (context, index) {
        final worker = DataStructure.jobs[index];
        return GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreatedJobs(
              worker: worker
            )));
          },
          child:Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(
              worker,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreatedJobs(
              worker: worker
            )));
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
              ),
              child: const Text('Provide details'),
            ),
          ),
        )
        );
      },
    );
  }
}
