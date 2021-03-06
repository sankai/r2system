#coding: UTF-8
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  # Association
  belongs_to :company
  has_many :engineorders
  
  # validation checks
  validates :userid, :presence => true,
                     :uniqueness => true,
                     :length => { :is => 8 },
                     :format => { :with => /\A[0-9A-Za-z]*\Z/}
  
  validates :name, :presence => true

  validates :email, :presence => true

  # このユーザーがYES本社の人かどうか
  def yesOffice?
    return self.company.category == "YES本社"
  end

  # このユーザーがYES拠点の人かどうか
  def yesBranch?
    return self.company.category == "YES拠点"
  end

  # このユーザーがYES本社、または拠点の人かどうか
  def yes?
    return (self.yesOffice?) || (self.yesBranch?)
  end

  # このユーザーが整備会社の人かどうか
  def tender?
    return self.company.category == "整備会社"
  end

  # このユーザーがシステム管理者かどうか
  # 暫定でYES本社の人は、すべてsystemAdminの扱いにする。
  def systemAdmin?
    return  (self.yesOffice?) || (self.company.category =="システム管理者")
  end

  # 会社を指定して、その会社のユーザのアドレスを全て;つながりで返す。
  def self.collect_emails_by_company(company)
    emails = ""
    users = self.where(:company => company)
    users.each do | user |
      emails = emails + user.email + ';'
    end
    return emails
  end

  #整備会社に所属するユーザーを取得する
  def self.tender_user_list
   company_list = Company.where(:category => "整備会社").pluck(:id)
   user_list = self.where(company_id: company_list)
   return user_list
  end

end
