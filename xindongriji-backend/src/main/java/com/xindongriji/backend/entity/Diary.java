/**
 * BEGINNER GUIDE:
 * File: Diary.java
 * Role: Domain entity: maps business objects to database tables.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.entity;

import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "diaries")
public class Diary {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false, length = 100)
  private String title;

  @Column(nullable = false, columnDefinition = "TEXT")
  private String content;

  @Column(nullable = false)
  private LocalDate date;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "user_id", nullable = false, foreignKey = @ForeignKey(name = "fk_diary_user"))
  private User user;

  @ManyToMany
  @JoinTable(
      name = "diary_tags",
      joinColumns = @JoinColumn(name = "diary_id", foreignKey = @ForeignKey(name = "fk_diary_tag_diary")),
      inverseJoinColumns = @JoinColumn(name = "tag_id", foreignKey = @ForeignKey(name = "fk_diary_tag_tag"))
  )
  private Set<Tag> tags = new HashSet<>();

  @CreationTimestamp
  @Column(updatable = false)
  private Instant createdAt;

  @UpdateTimestamp
  private Instant updatedAt;
}
