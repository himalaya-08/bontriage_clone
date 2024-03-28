class SiteNameModel {
  int? id;
  String? siteCode;
  String? siteName;
  String? coordinatorName;
  String? phNumber;
  String? email;
  bool? active;

  SiteNameModel(
      {this.id,
        this.siteCode,
        this.siteName,
        this.coordinatorName,
        this.phNumber,
        this.email,
        this.active});

  SiteNameModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteCode = json['site_code'];
    siteName = json['site_name'];
    coordinatorName = json['coordinator_name'];
    phNumber = json['ph_number'];
    email = json['email'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['site_code'] = this.siteCode;
    data['site_name'] = this.siteName;
    data['coordinator_name'] = this.coordinatorName;
    data['ph_number'] = this.phNumber;
    data['email'] = this.email;
    data['active'] = this.active;
    return data;
  }
}

